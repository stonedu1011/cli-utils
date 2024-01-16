#!/bin/bash

# Just Notes:
# ./authserver --> "authserver 1.32.1-SNAPSHOT"
# ./rpilmanager --> "rpilmanager 1.32.1-SNAPSHOT"
# ./swaggerservice --> "swaggerservice 1.32.1-SNAPSHOT"
# ./zuulserver --> "zuulserver 1.32.1-SNAPSHOT"

# ./accountservice --> "accountservice 1.32.12-SNAPSHOT"
# ./deviceservice --> "deviceservice 1.32.9-SNAPSHOT"
# ./channelmapservice --> "channelmapservice 1.32.4-SNAPSHOT"
# ./contentservice --> "contentservice 1.32.8-SNAPSHOT"
# ./mobileactivationservice --> "mobileactivationservice 1.32.11-SNAPSHOT"
# ./platformadservice --> "platformadservice 1.32.10-SNAPSHOT"

# ./accountintegrationservice --> "accountintegrationservice 1.32.6-SNAPSHOT"
# ./adminintegrationservice --> "adminintegrationservice 1.32.6-SNAPSHOT"
# ./channelmapintegrationservice --> "channelmapintegrationservice 1.32.6-SNAPSHOT"
# ./contentintegrationservice --> "contentintegrationservice 1.32.9-SNAPSHOT"
# ./coxplatformservice --> "coxplatformservice 1.32.5-SNAPSHOT"
# ./retaileradservice --> "retaileradservice 1.32.13-SNAPSHOT"

# ./eventpublishingservice --> "eventpublishingservice 1.32.5-SNAPSHOT"
# ./pinresetservice --> "pinresetservice 1.32.5-SNAPSHOT"
# ./platformservices --> "platformservices 1.32.4-SNAPSHOT"
# ./ppvservice --> "ppvservice 1.32.5-SNAPSHOT"
# ./remotedvrservice --> "remotedvrservice 1.32.4-SNAPSHOT"

# ./reportservice --> "reportservice 1.32.5-SNAPSHOT"
# ./transactionalvodservice --> "transactionalvodservice 1.32.6-SNAPSHOT"
# ./vodingestservice --> "vodingestservice 1.32.6-SNAPSHOT"
# ./vodingestintegrationservice --> "vodingestintegrationservice 1.32.6-SNAPSHOT"

TARGET_FOLDERS=(
  
  # "authserver" # No Config
  # "rpilmanager" # No Config
  # "swaggerservice"
  # "zuulserver"

  # "accountservice" # rpil config
  # "deviceservice" # rpil config, cox config on core-qa only
  # "channelmapservice" # rpil config
  # "contentservice" # rpil config
  # "mobileactivationservice" # rpil, comcast, saml config
  # "platformadservice" # rpil config
  #
  # "accountintegrationservice" # No Config
  # "adminintegrationservice" # No Config
  # "channelmapintegrationservice" # No Config
  # "contentintegrationservice" # rpil
  # "coxplatformservice" # mso config
  # "retaileradservice"  # retailer config = cox?
  #
  # "eventpublishingservice" # amazon config
  # "pinresetservice" # No Config
  # "platformservices" # No Config
  # "ppvservice" # Async executor, wpil at perf
  # "remotedvrservice" # No Config
  #
  "reportservice" # No Config
  "transactionalvodservice" # mso & rpil config, wpil endpoints on prod-1, prod-2 & cox-stg
  "vodingestservice" # rpil config
  "vodingestintegrationservice" # No Config
)

# handle-folder-validate() {
#   [ -e "$1/bin/rpilservice.sh" ]
# }

handle-prepare() {
  echo "Sync systemconfigurations/develop with remote ..."
  # DIR="/Workspace_STS/systemconfigurations/"
  # git --git-dir=$DIR/.git --work-tree=$DIR checkout develop
  # git --git-dir=$DIR/.git --work-tree=$DIR fetch
  # git --git-dir=$DIR/.git --work-tree=$DIR merge
  
  git --git-dir=$1/.git --work-tree=$1 checkout master
  git --git-dir=$1/.git --work-tree=$1 fetch
  git --git-dir=$1/.git --work-tree=$1 merge
}

backup-config-files() {
  [ ! -d "$1/conf/deprecated" ] && mkdir -p $1/conf/deprecated
  find $1/conf/ -maxdepth 1 -mindepth 1 -type f -name application-prod*.yml -print | \
    while read -r path; do
      BACKUP="${path/$1\/conf/$1/conf/deprecated}"
      [ ! -e $BACKUP ] && cp -p $path $BACKUP
      echo "${path/\.\//} "
    done
}

insert-file-descriptors() {
  COMMENT="$(grep 'Old Environment' $1/src/main/resources/assembly-configfiles.xml)"
  
  if [ ! -z "$COMMENT" ] ; then
    echo -e "${YELLOW}Warning:${NC} Skipped assembly descriptor update."
    return
  fi
  
  # Add Files to Descriptor
  sed -i "" "/<\/files>/{
    r /Workspace_STS/temp/ref-cloud-config/ref-assembly-configfiles-diff.xml
    d
  }" $1/src/main/resources/assembly-configfiles.xml 
}

handle-apply-changes() {
  cat << EOF
  
Note:
- Extract common components from conf/application.yml
- remove extracted content from conf/application.yml
- add files assembly descriptor (auto)
- increase version number

EOF

  FILES="$(backup-config-files $1)" 
  
  set -v
  # Insert files assembly descriptor
  insert-file-descriptors $1 $FILES
  
  # Extract content
  mate --no-wait /Workspace_STS/systemconfigurations/src/main/configfiles/
  mate -w $1/src/main/resources/application.yml $1/conf/application-x1-cox-prod-1.yml $FILES

  # Remove file and cleanup
  read -n 1 -p "Remove Config Files? [y/n]: " resp; echo
  if [ "$resp" == 'y' ]; then
    for path in $FILES ; do
      rm $path
    done
  fi
  
  mate -w $1/pom.xml
  set +v
}

handle-verify-changes() {
  
  CURRENT="$(pwd)"
  cd $1  
  # git --git-dir=$1/.git --work-tree=$1 difftool
  git diff src/main/resources/assembly-configfiles.xml
  git status
  
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
  echo "DE9087 - Cleaned prod-int and prod-int-2 yml files and added to assembly descriptor"
}

pre-push-changes() {
  return
}