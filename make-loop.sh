#!/bin/bash

delay=7

################ Example found in /usr/share/doc/util-linux/examples/getopt-parse.bash

TEMP=`getopt -o d: --long delay: -n "$0" -- "$@"`

if [ $? != 0 ] ; then echo "Abandon" >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"


while true ; do
  case "$1" in
    -d|--delay)
        delay=$2
        shift 2 ;;
    --) shift ; break ;;
    *) echo "Internal error!" ; exit 1 ;;
  esac
done

################ End example ##########################################################

last_notification=$(date '+%s')
make -s $*
while sleep $delay
do
  make -s $*
  if (( $? != 0 )) && (( $(date '+%s') - $last_notification > 17 )) # 17 is arbitrary
  then
    last_notification=$(date '+%s')
    notify-send "make error ($(date '+%H:%M:%S'))"
  fi
done
