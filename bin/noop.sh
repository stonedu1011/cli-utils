#!/bin/bash

# Import common functions
if command -v greadlink >/dev/null 2>&1; then
  SCRIPT_PATH=`greadlink -f $0`
else
  SCRIPT_PATH=`readlink -f $0`  
fi

source "$(dirname $SCRIPT_PATH)/functions"

print_usage() {
  cat << EOF

Script Description:
  No-op script that does nothing. Used to validate environment is ready to execute other scripts.
  
Usage: $(basename $0) [Global Options]

EOF

  print_global_options
}

parse_args() {
  return
}

### Main Script ###

# Initialize
colorize
if ! prepare "$@"; then
  print_usage
  exit 1
fi

parse_args "${ACTION_ARGS_UNPARSED[@]}"

# Execute
echo This is a No-op script. Nothing to do here
