#!/bin/bash

TARGET_FOLDERS=(

  "configurationserver"
  "authserver" # No Config
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
  # "reportservice" # No Config
  # "transactionalvodservice" # mso & rpil config, wpil endpoints on prod-1, prod-2 & cox-stg
  # "vodingestservice" # rpil config
  # "vodingestintegrationservice" # No Config
  
  # "shawaccountservice"
  # "shawassuranceservice"
  # "shawdeviceservice"
  # "shawplatformservice"
  
)

# handle-folder-validate() {
#   [ -e "$1/bin/rpilservice.sh" ]
# }

handle-prepare() {

  GITREPO="${1/\.\//}.git"
  echo "Cloning $GITREPO ..."
  git clone ssh://git@github.com:stonedu1011/rc/$GITREPO
}

handle-apply-changes() {
  git --git-dir=$1/.git --work-tree=$1 checkout develop
  return
}

handle-verify-changes() {
  return
}

pre-commit-changes() {
  return
}

customized-commit-message() {
  echo ""
}

pre-push-changes() {
  return
}