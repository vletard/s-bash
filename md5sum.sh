#!/bin/bash

if ! which realpath > /dev/null
then
  notify-send "$0: realpath was not found"
  exit 1
else
  IFS='
'
  
  absolute_executable=$(realpath $0)
  
  if [ "$absolute_executable" == "" ]
  then
    absolute_executable=$0
  fi
  
  for arg in $*
  do
    if test -d "$arg"
    then
      cd "$arg"
      sum=$(find . -maxdepth 1 -mindepth 1 -exec $absolute_executable {} \; | LANG=C sort | md5sum) # | cut -b -32)
      echo "$sum  $arg"
      cd - > /dev/null
    else
      md5sum "$arg"
    fi
  done
fi
