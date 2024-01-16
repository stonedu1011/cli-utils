#!/bin/bash

# Where am I?
if ! SCRIPT_PATH=`readlink -f $0 2>/dev/null` && ! SCRIPT_PATH=`greadlink -f $0 2>/dev/null`; then
    SCRIPT_PATH="$0"
    while symlink_src=`readlink $SCRIPT_PATH 2>/dev/null`
    do
      SCRIPT_PATH="$symlink_src"
    done
fi

# Script Constants
DEVENV_SCRIPT_DIR="devenv"
DEVENV_SCRIPT_PREFIX="devenv-"
DEVENV_SCRIPT_SUFIX=".script"
DEVENV_SCRIPT_FN_PREFIX="env_"
DEVENV_SCRIPT_FN_DOCKER_SUFIX="_docker"
DEVENV_SCRIPT_DEFAULT_PATH="$(dirname $SCRIPT_PATH)/$DEVENV_SCRIPT_DIR"
DEVENV_SCRIPT_ALT="default.script"
DEVENV_SCRIPT_ALT_SUFIX=".yml"
if [ -z "$DEV_ENV_PATH" ]; then
  DEVENV_SCRIPT_PATH="$DEVENV_SCRIPT_DEFAULT_PATH"
else
  DEVENV_SCRIPT_PATH="$DEV_ENV_PATH:$DEVENV_SCRIPT_DEFAULT_PATH"
fi

# Import common functions
source "$(dirname $SCRIPT_PATH)/functions"

### Generic Functions ###

print_usage() {
  cat << EOF

Script Description:
  Convenient utilities to control development environment of different project. 
  This script assumes that all required software are installed properly.
  
Usage: $(basename $0) [Global Options] <Action> [dev-environment] [Action Options] [Environment Specific Options]

Available Actions:
    list              List available environements
    info <env>        Show information of given environment. (services, supported options, etc)
    start <env>       Start services/containers
    stop <env>        Stop services/containers
    restart <env>     Stop services/containers
  
Action Options:
    -c|--containerized <true|false>:  
                         If run services in Docker container. Applicable if the cooresponding
                         script for the given environment support it.
                         Example: $(basename $0) start [env_name] -c false 
                         Default: true
    -h|-help|--help:     Show environment specific options. Same as 'info' command
  
EOF

  # print_common_action_options
  print_global_options
  
  cat << EOF

How to:
  - Add your development environment script
    You can write your own developement environment script, and name it as devenv-<your env name>.script. 
    The default location to put this script is 'devenv' directory. However, you can put it to anywhere
    and set an environement vairalbe 'DEV_ENV_PATH'. The value of this environement variable
    follows the same syntax rule of your normal search path ($PATH).
    
EOF
}

parse_args() {
  SUB_ACTION=""
  USE_DOCKER=true
  while [ "$#" -gt 0 ] ; do
    case "$1" in
      -c|--containerized)
        shift; 
        [ ! -z "$1" ] && USE_DOCKER=$1 && shift; 
        ;;
      *)
        [ -z "$SUB_ACTION" ] && SUB_ACTION="$1"
        shift
        ;;
    esac
  done
}

### Action Functions ###
# $1 if use docker
handle_action_with_sub_action() {
  if [ -z "$SUB_ACTION" ]; then
    echo_error "Please specify the environment name. Use '${YELLOW}$(basename $SCRIPT_PATH) list${NC}' to see available environments."
    return 1
  fi
  
  # Find the env script
  local script=""
  local alt_script=""
  local alt_descriptor=""
  IFS=':' read -r -a search_paths <<< "$DEVENV_SCRIPT_PATH"
  for path in "${search_paths[@]}"; do
    file="$path/${DEVENV_SCRIPT_PREFIX}${SUB_ACTION}${DEVENV_SCRIPT_SUFIX}"
    [ -e "$file" ] && script="$file"
    
    file="$path/${DEVENV_SCRIPT_ALT}"
    [ -e "$file" ] && alt_script="$file"
    
    file="$path/${DEVENV_SCRIPT_PREFIX}${SUB_ACTION}${DEVENV_SCRIPT_ALT_SUFIX}"
    [ -e "$file" ] && alt_descriptor="$file"
  done
   
  if [ -z "$script" ]; then
    if [ -z "$alt_script" -a -z "$alt_descriptor" ]; then
      echo_error "Invalid environment name '$SUB_ACTION'. Use '${YELLOW}$(basename $SCRIPT_PATH) list${NC}' to see available environments."
      return 1
    fi
    script="$alt_script"
  fi
  
  invoke_env_script "$script" $ACTION $1; ret=$?
  return $ret
}

# $1 script path
# $2 action
# $3 if use docker
invoke_env_script() {
  local script="$1"
  
  # Bring in the script
  source "$script"
  if [[ "$3" == "true" ]]; then
    local fn="$DEVENV_SCRIPT_FN_PREFIX${2/ /_}$DEVENV_SCRIPT_FN_DOCKER_SUFIX"
  else
    local fn="$DEVENV_SCRIPT_FN_PREFIX${2/ /_}"
  fi

  if ! command -v $fn >/dev/null 2>&1; then
    [[ "$3" == "true" ]] && local with_docker=" with Docker"
    echo_error "Environment [$1] doesn't support action '$2'$with_docker. Please check if function '$fn()' exists in script [$script]."
    return 1
  fi
  
  #sub shell
  (
    CURRENT_DEVENV_SCRIPT_DIR="$(dirname $script)"
    $fn "${ACTION_ARGS_UNPARSED[@]}"
  ); ret=$?
  return $ret
}

# $1 image pattern
docker_prepare_run() {
  docker_find_container "$1" && return 1
  if docker_find_container "$1" -a; then
    docker_remove_container "$1"
    return $?
  fi
}

# $1 image search pattern
# $2 -a if all
docker_find_container() {
  if [[ -z "$1" ]]; then
    echo_warn "Image search pattern cannot be empty. Can't stop containers"
    return 1
  fi
  
  local image="$1"
  local containers=`docker ps $2 | awk '{ print $1,$2 }' | grep "$image" | awk '{print $1 }'`
  if [ ! -z "$containers" ]; then
    if [ -z "$2" ]; then
      # only show this message for running containers
      echo_warn "Conaitners with image [$image] is already running: "
      echo $containers
      echo
    fi
    return
  fi
  return 1
}

# $1 image search pattern
docker_stop_container() {
  if [[ -z "$1" ]]; then
    echo_warn "Image search pattern cannot be empty. Can't stop containers"
    return 1
  fi
  
  echo_info "Stopping Containers ..."
  local image="$1"
  local containers=`docker ps | awk '{ print $1,$2 }' | grep "$image" | awk '{print $1 }'`
  echo $containers | xargs -I {} docker stop {}
  echo $containers | xargs -I {} docker wait {} >/dev/null 2>&1
  return $?
}

docker_remove_container() {
  if [[ -z "$1" ]]; then
    echo_warn "Image search pattern cannot be empty. Can't remove containers"
    return 1
  fi
  
  echo_info "Removing Containers ..."
  local image="$1"
  docker ps -a | awk '{ print $1,$2 }' | grep "$image" | awk '{print $1 }' | xargs -I {} docker rm {}
  return $?
}

### Action Functions ###
action_list() {
  echo
  echo "Available Developement Environment:"  
  printf "  %-10s %s\n" "Name" "Script"
  IFS=':' read -r -a search_paths <<< "$DEVENV_SCRIPT_PATH"
  for path in "${search_paths[@]}"; do
    [ -d $path ] || continue
    shopt -s nullglob
    for file in $path/$DEVENV_SCRIPT_PREFIX*$DEVENV_SCRIPT_SUFIX
    do
      local env_name="$(basename $file | sed -E "s|$DEVENV_SCRIPT_PREFIX(.*)$DEVENV_SCRIPT_SUFIX|\1|g")"
      printf "  \e${YELLOW}%-10s \e${NC}%s\n" "$env_name" "$file"
    done
  done
  
  echo
}

action_add() {
  [[ $USE_DOCKER ]] && local with_docker=" with Docker"
  echo_info "Load Properties$with_docker ..."
  handle_action_with_sub_action "$USE_DOCKER"; return $?
}

action_remove() {
  [[ $USE_DOCKER ]] && local with_docker=" with Docker"
  echo_info "Load Properties$with_docker ..."
  handle_action_with_sub_action "$USE_DOCKER"; return $?
}

action_info() {
  handle_action_with_sub_action; return $?
}

action_start() {
  [[ $USE_DOCKER ]] && local with_docker=" with Docker"
  echo_info "Starting$with_docker ..."
  handle_action_with_sub_action "$USE_DOCKER"; return $?
}

action_stop() {
  [[ $USE_DOCKER ]] && local with_docker=" with Docker"
  echo_info "Stopping$with_docker ..."
  handle_action_with_sub_action "$USE_DOCKER"; return $?
}

action_restart() {
  [[ $USE_DOCKER ]] && local with_docker=" with Docker"
  echo_info "Restarting$with_docker ..."
  handle_action_with_sub_action "$USE_DOCKER"; return $?
}

action_prepare() {
  [[ $USE_DOCKER ]] && local with_docker=" with Docker"
  echo_info "Preparing$with_docker ..."
  handle_action_with_sub_action "$USE_DOCKER"; return $?
}

### Main Script ###

# Initialize
colorize
if ! prepare "$@"; then
  if [ -z "$ACTION" ]; then
    print_usage  
    exit 1 
  fi
  
  parse_args "${ACTION_ARGS_UNPARSED[@]}"
  if [ -z "$SUB_ACTION" ]; then
    print_usage  
  else
    ACTION="info"
    dispatch_action $ACTION
  fi
  exit 1 
fi

parse_args "${ACTION_ARGS_UNPARSED[@]}"

# Check environement
if [ -z "$DEV_ENV_PATH" ]; then
  echo_warn "\$DEV_ENV_PATH is not set. Using default [$DEVENV_SCRIPT_PATH]"
fi

# Dispatch to action handler
dispatch_action $ACTION; ret=$?
exit $ret