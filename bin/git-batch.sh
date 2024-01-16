usage() {
  cat << EOF
  
Usage: $(basename $0) status|pull|master [Options]

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
    Handler Functions:
            handle-folder-validate()
    Action Functions:
            action-{name}()
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

### START Default Actions
action-pull() {
	echo -e "Repo [${YELLOW}$(get-repo-name $1)${NC}] Pulling... "
	
	if is-local-repo $1; 
	then
	 	echo -e "${YELLOW}local repo, skipped${NC}"
	else
    cd $1
		git pull
		echo ""
	fi
	
	cd - > /dev/null
}

action-status() {
	echo -ne "[${YELLOW}$(get-repo-name $1)${NC}] Status... "
  
	if is-local-repo $1; 
	then
	 	echo -e "${YELLOW}local repo, skipped${NC}"
	else
    cd $1
		changes=$(git status --porcelain)
	
		if [ -z "$changes" ];
		then
			echo -e "${GREEN}up-to-date${NC}"
		else
			echo -e "${RED}not up-to-date${NC}"
			echo $"$changes"
			echo ""
		fi
	fi
	
	cd - > /dev/null
}

action-master() {
	echo -e "Repo [${YELLOW}$(get-repo-name $1)${NC}] Checking out master... "
	
	if is-local-repo $1; 
	then
	 	echo -e "${YELLOW}local repo, skipped${NC}"
	else
    cd $1
		git checkout master
		echo ""
	fi
	
	cd - > /dev/null
}

### Handler Hooks
handle-folder-validate() {
  if is-local-repo $1 ; then
    return 1
  fi
}

### END Default Actions

### Helper Functions
get-repo-name() {
  basename `git --git-dir=$1/.git --work-tree=$1 rev-parse --show-toplevel`
}
### END Helper Functions


### Main scripts

ABS_PATH=`greadlink -f $0`
source "$(dirname $ABS_PATH)/batch-functions"

# Prepare
colorize
if ! parse-args "$@"; then
   usage; exit 1
fi
load-script $SCRIPT
[ $? -ne 0 -o -z "$VERB" ] && usage && exit 1

# Get Target List
LIST="$(prepare-list $BASE_DIR TARGET_FOLDERS[@])" && RET=$?
[ ! $RET ] && echo -e "\n${RED}WARNING: ${NC} Some items in TARGET_FOLDERS does not exist." 

# Perform action to each target folder
apply-action $VERB LIST[@]

