#!/bin/bash

# Just Notes:

TARGET_FOLDERS=(

  # "configurationserver"
  # "authserver" # No Config
  # "rpilmanager" # No Config
  # "swaggerservice"
  # "zuulserver"

  # "accountintegrationservice" # No Config
  # "accountservice" # rpil config
  # "adminintegrationservice" # rpil Config
  # "channelmapintegrationservice" # rpil Config
  # "channelmapservice" # rpil config
  # "contentintegrationservice" # rpil
  # "contentservice" # rpil config
  # "deviceservice" # rpil config, cox config on core-qa only
  # "eventpublishingservice" # amazon config
  # "mobileactivationservice" # rpil, comcast, saml config
  
  # "platformadservice" # rpil config
  # "retaileradservice"  # retailer config = cox?
  
  # "coxplatformservice" # mso config

  # "pinresetservice" # No Config
  # "platformservices" # No Config
  # "ppvservice" # Async executor, wpil at perf
  # "remotedvrservice" # No Config
  
  # "reportservice" # No Config
  # "transactionalvodservice" # mso & rpil config, wpil endpoints on prod-1, prod-2 & cox-stg
  # "vodingestservice" # rpil config
  # "vodingestintegrationservice" # No Config
  
  "shawaccountservice"
  "shawassuranceservice"
  "shawdeviceservice"
  "shawplatformservice"
)

# handle-folder-validate() {
#   [ -e "$1/bin/rpilservice.sh" ]
# }

handle-prepare() {
  echo "Sync repo with remote ..."
  
  git --git-dir=$1/.git --work-tree=$1 checkout master
  git --git-dir=$1/.git --work-tree=$1 fetch
  git --git-dir=$1/.git --work-tree=$1 merge
}

prepare-env-list() {
  SEARCH_ROOT="$1/configfiles/"
  find $SEARCH_ROOT -maxdepth 1 -mindepth 1 -type d -name x1* -print | \
    while read -r path; do
      echo "${path/$SEARCH_ROOT/} "
    done
}

insert-file-descriptors() {
  COMMENT="$(grep 'Shaw Environments' $1/src/main/resources/assembly-configfiles.xml)"
  
  if [ ! -z "$COMMENT" ] ; then
    echo -e "${YELLOW}Warning:${NC} Skipped assembly descriptor update."
    return
  fi
  
  # Add Files to Descriptor
  sed -i "" "/<\/files>/{
    r /Workspace_STS/temp/ref-shaw-config/ref-assembly-configfiles-diff.xml
    d
  }" $1/src/main/resources/assembly-configfiles.xml 
}

handle-apply-changes() {
  cat << EOF

Note:
- Copy YML files and rename them properly
- add files to assembly descriptors
- Make sure assembly is enabled in pom.xml

EOF

  ENVS="$(prepare-env-list /Workspace_STS/temp/ref-shaw-config)"
  
  set -v
  # Insert files assembly descriptor
  insert-file-descriptors $1
  
  # Copy Files and Rename
  FILES=""
  while read -r env; do
    SRC="$env/${1/\.\//}.yml.txt"
    DEST="application-$env.yml"
    
    if [ ! -e $1/conf/$DEST ] ; then
      echo -e "Copying ${YELLOW}$SRC${NC} --> $1/conf/${YELLOW}$DEST${NC} ..."
      cp /Workspace_STS/temp/ref-shaw-config/configfiles/$SRC $1/conf/$DEST
    else
      echo -e "$1/conf/${YELLOW}$DEST${NC} already exists, copy skipped."
    fi
    FILES="$FILES $1/conf/$DEST"
  done <<< "$ENVS"
  
  # Verify Files and Check pom.xml
  mate -w $1/src/main/resources/assembly-configfiles.xml $1/conf/application-x1-cox-int.yml $FILES $1/pom.xml

  set +v
}

handle-verify-changes() {
  
  CURRENT="$(pwd)"
  cd $1
  git diff
  git status
  
  mate -w src/main/resources/assembly-configfiles.xml pom.xml conf/
  echo -ne "${GREEN}Build and Test?${NC} [y/n]:"
  read -n 1 -p " " resp; echo
  [ "$resp" == 'y' ] || return 0
  
  mvn clean install
  cd $CURRENT
  return
}

pre-commit-changes() {
  CURRENT_DIR="$(pwd)"
  cd $1
  git checkout conf/deprecated/
  cd "$CURRENT_DIR"
}

customized-commit-message() {
  # echo "US22055 - Added config file for shaw environments."
  echo "US22055 - more config cleanup"
}

pre-push-changes() {
  return
}
