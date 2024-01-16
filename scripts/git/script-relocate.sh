# Relocate RPIL upstream

REPO_LOOKUP=(
    # Infrastructure Libraries
    "R-PIL-framework-libs rpil-parent"
    "R-PIL-framework-libs rpil-dependencies"
    "R-PIL-framework-libs rpilbase"
    "R-PIL-framework-libs rpil-integration"
    "R-PIL-framework-libs rpil-serialization"
    "R-PIL-framework-libs rpil-integration-wpil"
    "R-PIL-framework-libs rpil-async-request"
    "R-PIL-framework-libs rpilcommon-test"
    "R-PIL-framework-libs rpilcommon"
    "R-PIL-framework-libs rpilstarter"
    "R-PIL-framework-libs rpilmanagerui"
    "R-PIL-framework-libs minimalmicroservicearchetype"
        
    # Infrastructure service
    "R-PIL-framework-services authserver"
    "R-PIL-framework-services configurationserver"
    "R-PIL-framework-services discoveryserver"
    "R-PIL-framework-services rpilmanager"
    "R-PIL-framework-services swaggerservice"
    "R-PIL-framework-services zuulserver"
    "R-PIL-framework-services configurationviewer"

    # Infrastructure Others
    "R-PIL-framework-configs systemconfigurations"
    "R-PIL-framework-docs frameworkportingguide"
    "R-PIL-support-tools SimianArmy"
    "R-PIL-core-libs loadtestcommon"

    # uService
    "R-PIL-core-services accountservice"
    "R-PIL-core-services channelmapservice"
    "R-PIL-core-services contentservice"
    "R-PIL-core-services deviceservice"
    "R-PIL-core-services legacyservice"
    "R-PIL-core-services mobileactivationservice"
    "R-PIL-core-services pinresetservice"
    "R-PIL-core-services platformadservice"
    "R-PIL-core-services platformservices"
    "R-PIL-core-services ppvservice"
    "R-PIL-core-services remotedvrservice"
    "R-PIL-core-services reportservice"
    "R-PIL-core-services transactionalvodservice"
    "R-PIL-core-services vodingestservice"

    # integration service
    "R-PIL-core-services accountintegrationservice"
    "R-PIL-core-services adminintegrationservice"
    "R-PIL-core-services channelmapintegrationservice"
    "R-PIL-core-services contentintegrationservice"
    "R-PIL-core-services eventpublishingservice"
    "R-PIL-core-services retaileradservice"
    "R-PIL-core-services vodingestintegrationservice"

    # Cox services
    "R-PIL-cox-services coxplatformservice"
    
    # Shaw service
    "R-PIL-shaw-services shawplatformservice"
    "R-PIL-shaw-services shawdeviceservice"
    "R-PIL-shaw-services shawassuranceservice"
    "R-PIL-shaw-services shawaccountservice"
       
    # Utils
    "R-PIL-core-utils corerpilutils"
   
   # Deprecated
   "R-PIL-deprecated vci-rpil"
)

GIT_SSH_HOST="git@github.com:stonedu1011"

# $1 repo name
get-git-path() {
  for item in "${REPO_LOOKUP[@]}"
  do
    item_arr=($item)
    if [[ "${item_arr[1]}" = "$1" ]] ; then 
      echo "${item_arr[0]}/${item_arr[1]}.git"
      return 0
    fi
  done
  
  return 1
}

action-relocate() {
  
  # Repo Lookup
  REPO_NAME="$(basename $1)"
  GIT_PATH="$(get-git-path $REPO_NAME)"
  if [ -z $GIT_PATH ] ; then
    echo -e " - ${RED}Unknown Repository${NC} - Skipped" 
    return 1
  fi

  GIT_URL="$GIT_SSH_HOST:$GIT_PATH"
  echo -e " --> $GIT_URL"
  
  cd $1
  # Check if correct
  CURRENT_GIT_URL="$(git config --get remote.origin.url)"
  if [[ "$GIT_URL" = "$CURRENT_GIT_URL" ]] ; then 
    echo -e "${GREEN}[INFO]${NC} Current 'origin' URL is correct - Skipped"
    return
  fi
  
  # Check Connection  
  echo -ne "Verifying ... "
  git ls-remote "$GIT_URL" &> /dev/null || {
    echo -e "${RED}[ERROR] ${NC}Repository not accessable - Skipped" 
    return 1
  }
  echo -e "${GREEN}Good${NC}"
  
  # Set URL
  echo -ne "Relocating Local Repo ... "
  git remote set-url origin $GIT_URL && {
    echo -e " Set to ${GREEN}$(git config --get remote.origin.url)${NC}"
  }
}

action-show-origin() {
  cd $1
  CURRENT_GIT_URL="$(git config --get remote.origin.url)"
  echo -e " --> $CURRENT_GIT_URL"
}