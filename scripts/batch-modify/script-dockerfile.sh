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

  # "accountintegrationservice"
  # "adminintegrationservice"
  # "contentintegrationservice"
  # "eventpublishingservice"
  # "primehomeintegrationservice"
    
  # "coxplatformservice"
  # "shawaccountservice"
  # "shawassuranceservice"
  # "shawdeviceservice"
  # "shawplatformservice"
  
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
- Update Dockerfile (Auto)
- Update dockerlaunch.sh (Auto)

EOF
  
  SERVICENAME="$(echo $1 | gsed "s|.*/||g")"
  DEFAULT_DISCOVERY_URL='http://user:password@172.30.93.100:8761/eureka/'
  EXPOSE_CLAUSE="$(echo -n "$(gsed -nr 's/^ +port: +([0-9]+)/\1/p' $1/src/main/resources/bootstrap.yml)")"
  [ -z "$EXPOSE_CLAUSE" ] && EXPOSE_CLAUSE="$(echo -n "$(gsed -nr 's/^(EXPOSE) +([0-9]+)/\2/p' $1/Dockerfile)")"
  COPY_JAR_CLAUSE="$(echo -n "$(gsed -nr 's/^(ADD|COPY) +(.*jar.*)/\2/p' $1/Dockerfile)")"
  
  echo -e "SERVICE ${YELLOW}$SERVICENAME ${NC}"
  echo -e "EXPOSE ${YELLOW}$EXPOSE_CLAUSE ${NC}"
  echo -e "COPY ${YELLOW}$COPY_JAR_CLAUSE ${NC}" 
  echo 
  
  set -v
  # Update Dockerfile
  echo Auto Updating Dockerfile ...
  cp /Workspace_STS/temp/ref-dockerfile/Dockerfile $1/Dockerfile
  gsed -i "s|placeholder_port|${EXPOSE_CLAUSE}|g" $1/Dockerfile
  gsed -i "s|placeholder_copy_jar|${COPY_JAR_CLAUSE}|g" $1/Dockerfile
  # diffmerge /Workspace_STS/temp/ref-dockerfile/Dockerfile $1/Dockerfile
  
  # Update bin/dockerlaunch.sh
  echo Auto Updating dockerlaunch.sh ...
  cp /Workspace_STS/temp/ref-dockerfile/dockerlaunch.sh $1/bin/dockerlaunch.sh
  gsed -i "s|placeholder_service_name|${SERVICENAME}|g" $1/bin/dockerlaunch.sh
  gsed -i "s|placeholder_default_discovery_url|${DEFAULT_DISCOVERY_URL}|g" $1/bin/dockerlaunch.sh
  set +v
}

handle-verify-changes() {
  
  CURRENT="$(pwd)"
  cd $1  
  # git diff --ignore-space-at-eol
  git status
  mate -w Dockerfile bin/dockerlaunch.sh
  
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
  echo "US26270 - Updated Dockerfile and dockerlaunch.sh"
}

pre-push-changes() {
  return
}