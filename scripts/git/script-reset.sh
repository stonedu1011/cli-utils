# Relocate RPIL upstream

# REPO_LOOKUP=(
#
# )

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

action-reset() {
  git --git-dir=$1/.git --work-tree=$1 reset --hard 
}

action-show-origin() {
  cd $1
  CURRENT_GIT_URL="$(git config --get remote.origin.url)"
  echo -e " --> $CURRENT_GIT_URL"
}