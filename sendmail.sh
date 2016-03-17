#!/bin/bash

# defaults
from="$(printf "no-reply@factoriel.duckdns.org" )"
to=""
cc=""
bcc=""
date=$(date -R)
subject=""
message=$(cat)


TEMP=`getopt -o f:t:s:d: --long from:,to:,cc:,bcc:,subject:,date: -n "$0" -- "$@"`

if [ $? != 0 ] ; then echo "Abandon" >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

while true ; do
  case "$1" in
    -f|--from)    from=$2;    shift 2;;
    -s|--subject) subject=$2; shift 2;;
    -d|--date)    date=$2;    shift 2;;
    -t|--to)      if [ "$to" == "" ]
                  then
                    to=$2
                  else
                    to="$to,$2"
                  fi
                  shift 2;;
    --cc)         if [ "$cc" == "" ]
                  then
                    cc=$2
                  else
                    cc="$cc,$2"
                  fi
                  shift 2;;
    --bcc)        if [ "$bcc" == "" ]
                  then
                    bcc=$2
                  else
                    bcc="$bcc,$2"
                  fi
                  shift 2;;
    --) shift ; break ;;
    *) echo "Internal error!" ; exit 1 ;;
  esac
done

if [ "$to" == "" ]
then
  echo "At least one recipient is needed." >&2
  exit 1
fi

printf "From: %s\nTo: %s\nCC: %s\nBcc: %s\nDate: %s\nSubject: %s\nContent-Type: text/html; charset=\"UTF-8\"\n%s\n" "$from" "$to" "$cc" "$bcc" "$date" "$subject" "$message" | msmtp -t
