if [ ! -e ".idea" ]; then
  echo "Cannot find .idea in current folder."
  exit 1
fi
find . -type f -name "*.iml" | xargs sed -i '' -E 's/scope="{0,1}PROVIDED"{0,1} {0,1}//g'