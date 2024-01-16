#!/bin/bash

TARGET_FOLDERS=(
  
  # "authserver"
  # "rpilmanager"
  # "zuulserver"
  # "configurationserver"
  # "discoveryserver"

  # "accountservice"
  # "channelmapservice"
  # "contentservice"
  # "devicenotificationservice"
  # "deviceservice"
  # "mobileactivationservice"
  # "pinresetservice"
  # "platformservices"
  # "ppvservice"
  # "remotedvrservice"
  # "reportservice"
  # "transactionalvodservice"
  # "vodingestservice"

  "accountintegrationservice"
  "adminintegrationservice"
  "contentintegrationservice"
  "eventpublishingservice"
  "primehomeintegrationservice"
    
  "coxplatformservice"
  "shawaccountservice"
  "shawassuranceservice"
  "shawdeviceservice"
  "shawplatformservice"
  
  # Deprecated Services
  # "platformadservice"
  # "channelmapintegrationservice"
  # "retaileradservice"
  # "vodingestintegrationservice"
  
)

# handle-folder-validate() {
#   [ -e "$1/bin/dockerlaunch.sh" ]
# }

handle-prepare() {
  echo "Sync with remote ..."
  
  git --git-dir=$1/.git --work-tree=$1 checkout master
  git --git-dir=$1/.git --work-tree=$1 fetch
  git --git-dir=$1/.git --work-tree=$1 merge
}

handle-apply-changes() {
  cat << EOF
  
Note:
- Update dockerlaunch.sh (Auto)

EOF

  set -v
  # Update bin/dockerlaunch.sh
  echo Auto Updating dockerlaunch.sh ...
  gsed -i "s|^ *java|exec java|g" $1/bin/dockerlaunch.sh
  gsed -i "s|172.30.93.100|discoveryserver|g" $1/bin/dockerlaunch.sh
  set +v
}

handle-verify-changes() {
  
  CURRENT="$(pwd)"
  cd $1  
  git diff --ignore-space-at-eol
  git status
  
  # echo -ne "${GREEN}Build and Test?${NC} [y/n]:"
#   read -n 1 -p " " resp; echo
#   if [ "$resp" != 'y' ]; then
#     cd $CURRENT
#     return 0
#   fi
#
#   mvn clean install
#   [ ! -e target${1/.\///}.jar ] && echo -e "${YELLOW}Jar 'target${1/.\///}.jar' is not available!${NC}"
#   [ -e target${1/.\///}.jar ] && java -jar target${1/.\///}.jar --spring.cloud.config.enabled=true

  cd $CURRENT
  return
}

pre-commit-changes() {
  CURRENT_DIR="$(pwd)"
  cd $1

  cd "$CURRENT_DIR"
}

customized-commit-message() {
  echo "US26270 - Graceful shutdown in docker container"
}

pre-push-changes() {
  return
}