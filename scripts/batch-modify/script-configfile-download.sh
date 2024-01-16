#!/bin/bash

TARGET_FOLDERS=(
  
  "authserver"
  "rpilmanager"
  "swaggerservice"
  "zuulserver"

  "accountservice"
  "deviceservice"
  "channelmapservice"
  "contentservice"
  "mobileactivationservice"
  "platformadservice"

  "accountintegrationservice"
  "adminintegrationservice"
  "channelmapintegrationservice"
  "contentintegrationservice"
  "coxplatformservice"
  "retaileradservice"

  "eventpublishingservice"
  "pinresetservice"
  "platformservices"
  "ppvservice"
  "remotedvrservice"

  "reportservice" 
  "transactionalvodservice" 
  "vodingestservice" 
  "vodingestintegrationservice" 
  
  # "shawaccountservice"
  # "shawassuranceservice"
  # "shawdeviceservice"
  # "shawplatformservice"
)

# handle-folder-validate() {
#   [ -e "$1/bin/rpilservice.sh" ]
# }

handle-prepare() {
  echo "Sync systemconfigurations/develop with remote ..."
  
  git --git-dir=$1/.git --work-tree=$1 checkout release/v1.33
  git --git-dir=$1/.git --work-tree=$1 fetch
  git --git-dir=$1/.git --work-tree=$1 merge
}

download-config() {
  wget --no-check-certificate -d --header="Authorization: Bearer 153d9feb-8d96-4391-9df7-b48abae2dd11" -O /Workspace_STS/temp/ref-ymls/$SERVICENAME.yml https://173.37.34.161/rpilmanager/CONFIGURATIONSERVER_192_168_220_16/api/config/download?name=$SERVICENAME 
  return $?
}

handle-apply-changes() {
  cat << EOF
  
Note:
- Insert entries to bootstrap.yml (auto)
- increase version number

EOF
  
  set -v
  # Download
  SERVICENAME="${1/\.\//}"
  download-config $SERVICENAME
  RET=$?
  
  # check content and update pom
  if [ $RET -eq 0 ]; then
    diffmerge /Workspace_STS/temp/ref-ymls/$SERVICENAME.yml $1/conf/application-x1-shaw-prod-2.yml
  fi
  set +v
}

handle-verify-changes() {
  
  CURRENT="$(pwd)"
  cd $1  
  git diff --ignore-space-at-eol
  git status
  
  echo -ne "${GREEN}Build and Test?${NC} [y/n]:"
  read -n 1 -p " " resp; echo
  if [ "$resp" != 'y' ]; then
    cd $CURRENT
    return 0
  fi
  
  mvn clean install
  [ ! -e target${1/.\///}.jar ] && echo -e "${YELLOW}Jar 'target${1/.\///}.jar' is not available!${NC}" 
  [ -e target${1/.\///}.jar ] && java -jar target${1/.\///}.jar --spring.cloud.config.enabled=true
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
  echo "US22313 - Changed Health Aggregator order to DOWN,OUT_OF_SERVICE,UNKNOWN,UP"
}

pre-push-changes() {
  return
}