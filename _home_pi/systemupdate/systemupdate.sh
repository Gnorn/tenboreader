#!/bin/bash

cd /home/pi/systemupdate/tenboreader

version=$(cat VERSION)

echo "Current version is $version"

git pull https://github.com/Gnorn/tenboreader

newversion=$(cat VERSION)

echo "Downloaded version is $newversion"

if [[ "$version" == "$newversion" ]]
then
  echo "Already up to date"
else
  echo "Running update"
  ./update.sh
fi
