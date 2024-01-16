#!/bin/bash

if [ $# -ne 2 ]; 
then echo "Usage: $0 (source_folder) (dist_folder)" && exit 1
fi

SRC_FOLDER="$1"
DST_FOLDER="$2"
SEARCH="coxplatformservice"

if [ ! -d $SRC_FOLDER ]; then
  echo "Cannot find source folder: $SRC_FOLDER" && exit 1
fi

if [ ! -d $DST_FOLDER ]; then
  echo "Invalid target folder: '$DST_FOLDER' folder" && exit 1
fi

set -x

cp -rf $SRC_FOLDER/bin/rpilservice.sh $DST_FOLDER/bin/

echo ''
echo "Replacing strings: "
grep -r --col "$SEARCH" $DST_FOLDER
echo ''

sed -i "" "s|$SEARCH|$DST_FOLDER|g" $DST_FOLDER/bin/rpilservice.sh

echo "After replacement: "
grep -r --col "$SEARCH" $DST_FOLDER
echo ''

echo 'Checking diff...'
diffmerge -i $SRC_FOLDER/bin/rpilservice.sh $DST_FOLDER/bin/rpilservice.sh
