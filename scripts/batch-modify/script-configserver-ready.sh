#!/bin/bash

TARGET_FOLDERS=(
# 
# "accountservice"
# "deviceservice"
# "channelmapservice"
# "contentservice"
# "mobileactivationservice"
# "platformadservice"

# "accountintegrationservice"
# "adminintegrationservice"
# "channelmapintegrationservice"
# "contentintegrationservice"
# "retaileradservice"

# "coxplatformservice"

# "eventpublishingservice"
# "pinresetservice"
# "platformservices"
# "ppvservice"
# "remotedvrservice"

# "reportservice"
# "transactionalvodservice"
# "vodingestservice"
# "vodingestintegrationservice"

"shawaccountservice"
"shawassuranceservice"
"shawdeviceservice"
"shawplatformservice"
)

# handle-folder-validate() {
#   [ -e "$1/bin/rpilservice.sh" ]
# }

handle-prepare() {
  echo "Switch to master and pull ..."
  git --git-dir=$1/.git --work-tree=$1 checkout master
  git --git-dir=$1/.git --work-tree=$1 fetch
  git --git-dir=$1/.git --work-tree=$1 merge
}

handle-apply-changes() {
  cat << EOF
  
Note:
- Add cloud config related configurations in boostrap.yml
- Move content from application.yml to boostrap.yml
- Copy content from application-development.yml to application.xml
- Remove RPM packaging in pom.xml
- Add config packaging descriptor
- remove "conf/" from config path in rpilservices.sh
- add eureka & cloud config related cli args in rpilservices.sh
- copy assembly descriptors
- add yml if missing 
- restore sensu/check-service-health.json 

EOF
  set -v
  mate -w $1/src/main/resources/bootstrap.yml $1/src/main/resources/application.yml $1/local/application-development.yml /Workspace_STS/temp/ref-cloud-config/ref-bootstrap-authserver.yml /Workspace_STS/temp/ref-cloud-config/ref-application.yml
  diffmerge /Workspace_STS/temp/ref-cloud-config/ref-pom.xml $1/pom.xml
  diffmerge /Workspace_STS/temp/ref-cloud-config/ref-rpilservice.sh $1/bin/rpilservice.sh
  cp /Workspace_STS/temp/ref-cloud-config/ref-assembly-configfiles-shaw.xml $1/src/main/resources/assembly-configfiles.xml

  [ ! -e $1/sensu/check-service-health.json ] && cp temp/ref-cloud-config/check-service-health.json $1/sensu/check-service-health.json

  [ ! -e $1/conf/application-x1-shaw-dev.yml ] && cp /Documents/batch/shaw-yaml-11162015/x1-shaw-dev/$1.yml $1/conf/application-x1-shaw-dev.yml
  [ ! -e $1/conf/application-x1-shaw-int.yml ] && cp /Documents/batch/shaw-yaml-11162015/x1-shaw-int/$1.yml $1/conf/application-x1-shaw-int.yml
  [ ! -e $1/conf/application-x1-shaw-prod-1.yml ] && cp /Documents/batch/shaw-yaml-11162015/x1-shaw-prod-1/$1.yml $1/conf/application-x1-shaw-prod-1.yml  
  [ ! -e $1/conf/application-x1-shaw-prod-2.yml ] && cp /Documents/batch/shaw-yaml-11162015/x1-shaw-prod-2/$1.yml $1/conf/application-x1-shaw-prod-2.yml
  set +v
}

handle-verify-changes() {
  
  git --git-dir=$1/.git --work-tree=$1 status
  
  echo -ne "${GREEN}Build and Test?${NC} [y/n]:"
  read -n 1 -p " " resp; echo
  [ "$resp" == 'y' ] || return 0
  
  CURRENT="$(pwd)"
  cd $1
  mvn clean install -Prpm
  mvn spring-boot:run
  cd $CURRENT
  return
}

customized-commit-message() {
  echo "US22056 - Enabled configuration server. YML files for environments is not verified"
}

pre-push-changes() {
  return
}