#!/bin/bash

TARGET_FOLDERS=(
  
# "authserver"
# "rpilmanager"
# "swaggerservice"
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
  git --git-dir=$1/.git --work-tree=$1 checkout master
  git --git-dir=$1/.git --work-tree=$1 fetch
  git --git-dir=$1/.git --work-tree=$1 merge
}

update-descriptors() {

  # update descriptors
  git --git-dir=$1/.git --work-tree=$1 checkout master
  git --git-dir=$1/.git --work-tree=$1 fetch origin release/v1.34
  git --git-dir=$1/.git --work-tree=$1 merge FETCH_HEAD
  
  mate -w $1/pom.xml
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
  echo "DE9223 - Apply fixes from patch to master"
}

pre-push-changes() {
  return
}