#!/bin/bash

# sha 256 is default (recommended)
checksum_executable=sha256sum

HELP="Usage: $0 [-a checksum_executable] [FILE]..."
TEMP=`getopt -o a:h --long algorithm:,help -n "$0" -- "$@"`

if [ $? != 0 ] ; then echo "Abandon" >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

while true ; do
	case "$1" in
		-a|--algorithm) checksum_executable=$2 ; shift 2 ;;
		-h|--help) echo "$HELP"
                           exit 0 ;;
		--) shift ; break ;;
		*) echo "Internal error!" ; exit 1 ;;
	esac
done

if ! which $checksum_executable > /dev/null
then
  echo "$checksum_executable was not found" >&2
  exit 1
fi

if (( $# == 0 ))
then
  $checksum_executable
else
  if ! which realpath > /dev/null
  then
    echo "$0: realpath was not found" >&2
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
        sum=$(find . -maxdepth 1 -mindepth 1 | LANG=C sort | xargs -0 $absolute_executable | $checksum_executable) # | cut -b -32)
        printf "\033[2K" >&2
        echo "$sum  $arg"
        cd - > /dev/null
      else
        printf "\033[2K%s\r" "$arg" >&2
        $checksum_executable "$arg"
      fi
    done
  fi
fi

