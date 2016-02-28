#!/bin/bash

if (( $# == 0 ))
then
  md5sum
else
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
        sum=$(find . -maxdepth 1 -mindepth 1 | LANG=C sort | xargs -0 $absolute_executable | md5sum) # | cut -b -32)
        printf "\033[2K" >&2
        echo "$sum  $arg"
        cd - > /dev/null
      else
        printf "\033[2K%s\r" "$arg" >&2
        md5sum "$arg"
      fi
    done
  fi
fi
