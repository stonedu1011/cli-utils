#!/bin/bash

usage() {
  cat << EOF
  
Usage: $(basename $0) prepare|apply|verify|commit|push|version|summary [Options]

Options:
EOF

  print-standard-options
  
  # Additional Options
  cat << EOF
  
EOF

  # Customized Script
  cat << EOF
Customized Script: 
    Script specified by -s|--script need to define at least one of following:
    Functions:
            handle-folder-validate()
            handle-prepare()
            handle-apply-changes()
            handle-verify-changes()
            pre-commit-changes()
            customized-commit-message()
            pre-push-changes()
    Variables:
            \$TARGET_FOLDERS array To override folder search result

EOF

	exit
}

# $1 path to script
load-script() {
  if [ ! -z "$1" ]; then
    source $SCRIPT
  fi
}

### Job related, customizable
handle-folder-validate() {
  [ -e "$1/bin/rpilservice.sh" ]
}

handle-prepare() {
  echo "Preparation with args $@"
}

handle-apply-changes() {
  set -v
  echo "Apply changes with args $@"
  set +v
}

handle-verify-changes() {
  return
}

pre-commit-changes() {
  return;
}

customized-commit-message() {
  echo "ld - this is batch modification script"
}

pre-push-changes() {
  return
}
### End Customizable Jobs

### Standard Routines
action-prepare() {
  read -n 1 -p "Make preparation? [y/n]: " resp; echo
  [ "$resp" == 'y' ] || return 1
  
  handle-prepare "$@"
  return 0
}

action-apply() {
  read -n 1 -p "Apply changes? [y/n]: " resp; echo
  [ "$resp" == 'y' ] || return 1
  
  echo "Applying changes... "
  handle-apply-changes "$@"
  echo -e "${GREEN}[ Done ]${NC}"
}

action-verify() {
  
  REPO="$1"
  read -n 1 -p "Start to verify? [y/n]: " resp; echo
  [ "$resp" == 'y' ] || return 1
  
  echo "Verifying changes..."
  
  handle-verify-changes "$@"
  
  echo -ne "Everything OK? (${YELLOW}$REPO${NC}) [y/n]:"
  read -n 1 -p " " resp; echo
  [ "$resp" == 'y' ] || return 1
  
  echo -e "${GREEN}[ Done ]${NC}"
}

action-commit() {
  pre-commit-changes "$@"
  
  git --git-dir=$1/.git --work-tree=$1 status
  
  read -n 1 -p "Commit Changes? [y/n]: " resp; echo
  [ "$resp" == 'y' ] || return 1
  
  echo "Committing changes..."
  COMMIT_MSG=$(customized-commit-message "$@")
  echo "commit msg: $COMMIT_MSG"
  set -v
  git --git-dir=$1/.git --work-tree=$1 add -A
  git --git-dir=$1/.git --work-tree=$1 commit -m "$COMMIT_MSG"
  set +v
  echo -e "${GREEN}[ Done ]${NC}"
}

action-push() {
  read -n 1 -p "Push to upstream? [y/n]: " resp; echo
  [ "$resp" == 'y' ] || return 1
  
  echo "Pushing changes..."
  pre-push-changes "$@"
  git --git-dir=$1/.git --work-tree=$1 push
  echo -e "${GREEN}[ Done ]${NC}"
}

action-version() {
  if [ ! -e $1/pom.xml ] ; 
    then return 1; 
  fi
  ARTIFACT=$(cat $1/pom.xml | grep -E -m 1 '.*<artifactId>(.*)<\/artifactId>.*' | sed -E 's/.*<artifactId>(.*)<\/artifactId>.*/\1/')
  VERSION=$(cat $1/pom.xml | grep -E -m 1 '.*<version>(.*)<\/version>.*' | sed -E 's/.*<version>(.*)<\/version>.*/\1/')
  [ ! -z "$VERSION" ] && echo -ne "--> \"${YELLOW}${ARTIFACT} ${GREEN}${VERSION}${NC}\""
}

action-summary() {
  if [ ! -e $1/pom.xml ] ; 
    then return 1; 
  fi
  ARTIFACT=$(cat $1/pom.xml | grep -E -m 1 '.*<artifactId>(.*)<\/artifactId>.*' | sed -E 's/.*<artifactId>(.*)<\/artifactId>.*/\1/')
  VERSION=$(cat $1/pom.xml | grep -E -m 1 '.*<version>(.*)<\/version>.*' | sed -E 's/.*<version>(.*)<\/version>.*/\1/')
  SERVER_PORT="$(echo -n "$(gsed -nr 's/^ +port: +([0-9]+)/\1/p' $1/src/main/resources/bootstrap.yml)")"
  [ -z "$SERVER_PORT" ] && SERVER_PORT="$(echo -n "$(gsed -nr 's/^(EXPOSE) +([0-9]+)/\2/p' $1/Dockerfile)")"
  echo -ne "- [Version = ${GREEN}${VERSION}${NC}]  [Port = ${YELLOW}${SERVER_PORT}${NC}]"
}
### End Standard Routines

### Main scripts

ABS_PATH=`greadlink -f $0`
source "$(dirname $ABS_PATH)/batch-functions"

# Prepare
colorize && parse-args "$@"
load-script $SCRIPT
[ $? -ne 0 -o -z "$VERB" ] && usage && exit 1

# Get Target List
LIST="$(prepare-list $BASE_DIR TARGET_FOLDERS[@])" && RET=$?
[ ! $RET ] && echo -e "\n${RED}WARNING: ${NC} Some items in TARGET_FOLDERS does not exist." 

# Perform action to each target folder
apply-action $VERB LIST[@]
