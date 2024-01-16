#!/bin/sh

export VAULT_ADDR="http://vault:8200"
export VAULT_STORAGE_DIR="/vault/file"

# Gather status
initialized=`vault status -format=json | jq -r '.initialized'`
sealed=`vault status -format=json | jq -r '.sealed'`

# Initialize or Grab ROOT TOKEN
if [ "$initialized" = "false" ]; then
  # initialize with single unseal key
  echo "Initializing Vault ..."
  vault operator init -format=json -key-shares=1 -key-threshold=1 >$VAULT_STORAGE_DIR/init.json 2>&1;
  if [ ! $? ]; then
    echo "Faild to initialize"
    exit 255
  fi
fi

export VAULT_ROOT_TOKEN_ID=`cat $VAULT_STORAGE_DIR/init.json | jq -r '.root_token'`
export VAULT_TOKEN=$VAULT_ROOT_TOKEN_ID
echo "Root Token: $VAULT_ROOT_TOKEN_ID"

# Unseal if necessary
if [ "$sealed" = "true" ]; then
  unseal_key=`cat $VAULT_STORAGE_DIR/init.json | jq -r '.unseal_keys_b64[0]'`
  echo "Unsealing Vault with Key [$unseal_key] ..."
  vault operator unseal -format=json $unseal_key >$VAULT_STORAGE_DIR/unseal.json 2>&1
  if [ ! $? ]; then
    echo "Faild to unseal"
    exit 255
  fi
fi

# Wait until unsealed
while ! vault status >/dev/null 2>&1;
do
  sleep 1;
done;

# Create Dev Token
if ! vault token lookup $VAULT_DEV_ROOT_TOKEN_ID >/dev/null 2>&1; then
  echo "Creating Dev Token [$VAULT_DEV_ROOT_TOKEN_ID] ..."
  vault token create -format=json \
    -display-name="dev-default" \
    -id=replace_with_token_value \
    -ttl=87600h \
    -policy=root -policy=default \
    -orphan >$VAULT_STORAGE_DIR/dev_token.json 2>&1
  if [ ! $? ]; then
    echo "Failed to create Dev Token"
    exit 255
  fi
else
  echo "Dev Token [$VAULT_DEV_ROOT_TOKEN_ID] already existed"
fi

# Switch to the dev token
export VAULT_TOKEN=$VAULT_DEV_ROOT_TOKEN_ID

# $1 name
# $2 version
function createKV() {
  n="$1"
  v="$2"
  current=`vault secrets list -format=json | jq -r ".[\"$n/\"].options.version"`
  if [ "$current" = "$v" ]; then
    echo "'$n/' is already mounted as kv engine v$v"
  else
    if [ "$current" != "null" ]; then
      echo "current kv engine version at '$n/' is $current"
      vault secrets disable $n/
    fi
    vault secrets enable -path=$n -version=$v kv
    echo "kv engine v$v created at '$n/'"
  fi
}

# $1 engine
function createOther() {
    engine="$1"
    current=`vault secrets list -format=json | jq -r ".[\"$engine/\"].type"`
    if [ "$current" = "$engine" ]; then
      echo "'$engine/' is already mounted as $engine engine"
    else
      if [ "$current" != "null" ]; then
        echo "current engine type at '$engine/' is $current"
        vault secrets disable $engine/
      fi
      vault secrets enable $engine
      echo "$engine engine created at '$engine/'"
    fi
}

# Enable some secret engines
createOther "transit"
createOther "totp"

# Create "secret/" to kv v1 if not everted yet
createKV "secret" 1

# create kv v2 store with different name "v2secret" (new since 3.8.0)
createKV "v2secret" 2
