#!/bin/sh
export VAULT_TOKEN=$VAULT_DEV_ROOT_TOKEN_ID
export VAULT_ADDR="http://vault:8200"

while ! vault status >/dev/null 2>&1;
do
  sleep 1;
done;

# Enable some secret engines
vault secrets enable transit
vault secrets enable totp

# convert default "secret/" to kv v1 if not everted yet
current=`vault secrets list -format=json | jq -r '.["secret/"].options.version'`
echo "current kv engine version at 'secret/' is $current"
if [ "$current" -ne "1" ]; then
  vault secrets disable secret/
  vault secrets enable -path=secret -version=1 kv
  echo "kv engine v1 created at 'secret/'"
else
  echo "'secret/' is already mounted as kv engine v1"
fi
