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
  
  "shawaccountservice"
  "shawassuranceservice"
  "shawdeviceservice"
  "shawplatformservice"
)

# handle-folder-validate() {
#   [ -e "$1/bin/rpilservice.sh" ]
# }

handle-prepare() {
  echo "Sync systemconfigurations/develop with remote ..."
  
  git --git-dir=$1/.git --work-tree=$1 checkout master
  git --git-dir=$1/.git --work-tree=$1 fetch
  git --git-dir=$1/.git --work-tree=$1 merge
}

insert-config-entries() {
  KEYWORD="$(grep '^ \+health:' $1/src/main/resources/bootstrap.yml)"
  
  if [ ! -z "$KEYWORD" ] ; then
    echo -e "${YELLOW}Warning:${NC} Skipped bootstrap.yml update."
    return
  fi
  
  # Add entry at end of management section
  # Note: only works with gnu-sed because Mac sed doesn't escape \r
  gsed -E -n -i '/^[[:space:]]*$/b section
  H
  $ b section
  b
  :section
  x
  s/\r//g
  p
  /(\nmanagement:)|(^management:)/ {
    r /Workspace_STS/temp/ref-health-indicators/bootstrap-diff.yml
  }
  ' $1/src/main/resources/bootstrap.yml
}

handle-apply-changes() {
  cat << EOF
  
Note:
- Insert entries to bootstrap.yml (auto)
- increase version number

EOF
  
  set -v
  # Insert config entries
  insert-config-entries $1
  
  # check content and update pom
  mate -w $1/src/main/resources/bootstrap.yml $1/pom.xml
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