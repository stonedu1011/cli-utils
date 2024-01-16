#!/bin/bash

# Just Notes:
# ./accountservice --> "accountservice 1.32.7-SNAPSHOT"
# ./deviceservice --> "deviceservice 1.32.3-SNAPSHOT"
# ./channelmapservice --> "channelmapservice 1.32.1-SNAPSHOT"
# ./contentservice --> "contentservice 1.32.3-SNAPSHOT"
# ./mobileactivationservice --> "mobileactivationservice 1.32.3-SNAPSHOT"
# ./platformadservice --> "platformadservice 1.32.4-SNAPSHOT"

# ./accountintegrationservice --> "accountintegrationservice 1.32.2-SNAPSHOT" # No config
# ./adminintegrationservice --> "adminintegrationservice 1.32.2-SNAPSHOT" # No config
# ./channelmapintegrationservice --> "channelmapintegrationservice 1.32.1-SNAPSHOT" # No config
# ./contentintegrationservice --> "contentintegrationservice 1.32.3-SNAPSHOT"
# ./coxplatformservice --> "coxplatformservice 1.32.2-SNAPSHOT" # mso config
# ./retaileradservice --> "retaileradservice 1.32.6-SNAPSHOT"

# ./eventpublishingservice --> "eventpublishingservice 1.32.2-SNAPSHOT" # amazon config
# ./pinresetservice --> "pinresetservice 1.32.2-SNAPSHOT" # No Config
# ./platformservices --> "platformservices 1.32.1-SNAPSHOT" # Cox config
# ./ppvservice --> "ppvservice 1.32.2-SNAPSHOT" # Async executor, wpil at perf
# ./remotedvrservice --> "remotedvrservice 1.32.1-SNAPSHOT" # No Config

# ./reportservice --> "reportservice 1.32.2-SNAPSHOT" # No Config
# ./transactionalvodservice --> "transactionalvodservice 1.32.2-SNAPSHOT" # mso & rpil config, wpil endpoints on prod-1, prod-2 & cox-stg
# ./vodingestservice --> "vodingestservice 1.32.2-SNAPSHOT" # rpil config
# ./vodingestintegrationservice --> "vodingestintegrationservice 1.32.2-SNAPSHOT" # No Config

TARGET_FOLDERS=(

  # "accountservice" # rpil config
  # "deviceservice" # rpil & cox config
  # "channelmapservice" # rpil config
  # "contentservice" # rpil config
  # "mobileactivationservice" # rpil, mso, comcast, saml config
  # "platformadservice" # rpil config

  # "accountintegrationservice" # No Config
  # "adminintegrationservice" # No Config
  # "channelmapintegrationservice" # No Config
  # "contentintegrationservice" # rpil
  # "coxplatformservice" # mso config
  # "retaileradservice"  # retailer config = cox?
  
  # "eventpublishingservice" # amazon config
  # "pinresetservice" # No Config
  # "platformservices" # Cox config
  # "ppvservice" # Async executor, wpil at perf
  # "remotedvrservice" # No Config
  
  # "reportservice" # No Config
  # "transactionalvodservice" # mso & rpil config, wpil endpoints on prod-1, prod-2 & cox-stg
  # "vodingestservice" # rpil config
  # "vodingestintegrationservice" # No Config
)

# handle-folder-validate() {
#   [ -e "$1/bin/rpilservice.sh" ]
# }

handle-prepare() {
  echo "Sync systemconfigurations/develop with remote ..."
  DIR="/Workspace_STS/systemconfigurations/"
  git --git-dir=$DIR/.git --work-tree=$DIR checkout develop
  git --git-dir=$DIR/.git --work-tree=$DIR fetch
  git --git-dir=$DIR/.git --work-tree=$DIR merge
  
  DIR="/Workspace_STS/systemconfigurations/"
  git --git-dir=$1/.git --work-tree=$1 checkout master
  git --git-dir=$1/.git --work-tree=$1 fetch
  git --git-dir=$1/.git --work-tree=$1 merge
}

backup-config-files() {
  [ ! -d "$1/conf/deprecated" ] && mkdir -p $1/conf/deprecated
  find $1/conf/ -maxdepth 1 -mindepth 1 -type f -name application-x1*.yml -print | \
    while read -r path; do
      BACKUP="${path/$1\/conf/$1/conf/deprecated}"
      [ ! -e $BACKUP ] && cp -p $path $BACKUP
      echo "${path/\.\//} "
    done
}

handle-apply-changes() {
  cat << EOF
  
Note:
- Extract common components from conf/application.yml
- remove extracted content from conf/application.yml
- increase version number

EOF

  FILES="$(backup-config-files $1)" 
  
  set -v
  # Extract content
  # mate --no-wait /Workspace_STS/systemconfigurations/src/main/configfiles/
  mate -w $1/src/main/resources/application.yml $FILES

  # Remove file and cleanup
  # read -n 1 -p "Remove Config Files? [y/n]: " resp; echo
  # if [ "$resp" == 'y' ]; then
  #   for path in $FILES ; do
  #     rm $path
  #   done
  # fi
  
  # mate -w $1/pom.xml
  set +v
}

handle-verify-changes() {
  
  # git --git-dir=$1/.git --work-tree=$1 difftool
  git --git-dir=$1/.git --work-tree=$1 status
  
  echo -ne "${GREEN}Build and Test?${NC} [y/n]:"
  read -n 1 -p " " resp; echo
  [ "$resp" == 'y' ] || return 0
  
  CURRENT="$(pwd)"
  cd $1
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
  echo "US21129 - Part 2 Config file cleanup & normalization"
  # echo "US21129 - Part 2 removed wpil configuration from config files"
  # echo "US21129 - Part 2 Config file cleanup & removed not-in-use configs"
}

pre-push-changes() {
  return
}