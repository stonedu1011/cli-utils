#!/bin/bash

TARGET_FOLDERS=(
  
  # "authserver"
  # "rpilmanager"
  "swaggerservice"
  "zuulserver"

  "accountservice"
  "deviceservice"
  "channelmapservice"
  "contentservice"
  "mobileactivationservice"
  "platformadservice"

  # "accountintegrationservice"
  "adminintegrationservice"
  "channelmapintegrationservice"
  "contentintegrationservice"
  # "coxplatformservice"
  "retaileradservice"

  # "eventpublishingservice"
  "pinresetservice"
  # "platformservices"
  # "ppvservice"
  # "remotedvrservice"

  # "reportservice" 
  # "transactionalvodservice" 
  "vodingestservice" 
  # "vodingestintegrationservice"
  
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
  
  git --git-dir=$1/.git --work-tree=$1 fetch
  git --git-dir=$1/.git --work-tree=$1 checkout release/v1.34
  git --git-dir=$1/.git --work-tree=$1 fetch
  git --git-dir=$1/.git --work-tree=$1 merge
}

update-descriptor() {
  KEYWORD="application-$2.yml"
  
  gsed -E -i "/$KEYWORD/ {
    N
    s|<outputDirectory>.*</outputDirectory>|<outputDirectory>$2</outputDirectory>|
  }" $1/src/main/resources/assembly-configfiles.xml

}

update-descriptors() {
  
  KEYWORD="$(grep 'application-x1-shaw-' $1/src/main/resources/assembly-configfiles.xml)"
  if [ -z "$KEYWORD" ] ; then
    echo -e "${YELLOW}Warning:${NC} Skipped assembly-configfiles.xml update..."
    return 1
  fi

  # update descriptors
  update-descriptor $1 x1-shaw-dev
  update-descriptor $1 x1-shaw-int
  update-descriptor $1 x1-shaw-prod-1
  update-descriptor $1 x1-shaw-prod-2
}

handle-apply-changes() {
  cat << EOF
  
Note:
- Update assembly-configfiles.xml (auto)

EOF
  
  set -v
  # Insert config entries
  update-descriptors $1
  [ $? -ne 0 ] && return 1
  
  # check diff
  git --git-dir=$1/.git --work-tree=$1 diff
  set +v
}

handle-verify-changes() {
  
  CURRENT="$(pwd)"
  cd $1  
  git diff --ignore-space-at-eol
  git status
  
  # echo -ne "${GREEN}Build and Test?${NC} [y/n]:"
  # read -n 1 -p " " resp; echo
  # if [ "$resp" != 'y' ]; then
  #   cd $CURRENT
  #   return 0
  # fi
  #
  # mvn clean install
  # [ ! -e target${1/.\///}.jar ] && echo -e "${YELLOW}Jar 'target${1/.\///}.jar' is not available!${NC}"
  # [ -e target${1/.\///}.jar ] && java -jar target${1/.\///}.jar --spring.cloud.config.enabled=true
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
  echo "DE9223 - Fixed assembly descriptors for shaw environments"
}

pre-push-changes() {
  return
}