#!/bin/bash

# Recursively encrypts the files given in argument to stdout

pass=

################ Example found in /usr/share/doc/util-linux/examples/getopt-parse.bash

TEMP=`getopt -o f: --long key-file: -n "$0" -- "$@"`

if [ $? != 0 ] ; then echo "Abandon" >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

while true ; do
  case "$1" in
    -f|--key-file)     
      pass=$(tr -d '\\n' < $2)
      shift 2 ;;
    --) shift ; break ;;
    *) echo "Internal error!" ; exit 1 ;;
  esac
done

################ End example ##########################################################

if [ "$pass" = "" ]
then
  printf "Enter passphrase: " >&2
  read -s pass
  printf "\n\n" >&2
fi

printf "Warning: encoding to stdout!\nctrl-c to cancel\n\n" >&2
sleep 17
tar cvz "$@" | openssl aes-256-cbc -salt -pass "pass:$pass"
