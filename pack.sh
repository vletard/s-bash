#!/bin/bash

# Recursively encrypts the files given in argument to stdout

pass=
output=

################ Example found in /usr/share/doc/util-linux/examples/getopt-parse.bash

TEMP=`getopt -o f:ho: --long key-file:,help -n "$0" -- "$@"`

if [ $? != 0 ] ; then echo "Abandon" >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

while true ; do
  case "$1" in
    -f|--key-file)     
      pass=$(tr -d '\\n' < $2)
      shift 2 ;;
    -o)
      output=$2
      shift 2 ;;
    -h|--help)
      shift $# ; break ;;
    --) shift ; break ;;
    *) echo "Internal error!" ; exit 1 ;;
  esac
done

################ End example ##########################################################

if (( $# < 1 ))
then
  printf "Usage: %s [-f PASS_FILE] [-l] [-o OUTPUT_FILE] FILE[S]\n" "$0" >&2
  printf "\nOptions:\n" >&2
  printf "   -f, --key-file      reads the content of PASS_FILE as password instead of prompting from stdin\n" >&2
  printf "   -o                  encrypts the FILES into OUTPUT_FILE instead of stdout\n" >&2
  printf "   -h, --help          prints this message\n" >&2
  exit 1
fi


if [ "$pass" = "" ]
then
  printf "Enter passphrase: " >&2
  read -s pass
  printf "\n\n" >&2
  printf "Confirm passphrase: " >&2
  read -s pass2
  printf "\n\n" >&2
  if [ "$pass2" != "$pass" ]
  then
    echo "Non matching passphrases, aborting." >&2
    exit 1
  fi
fi

if test -z $output
then
  printf "Warning: encoding to stdout!\nctrl-c to cancel\n\n" >&2
  sleep 17
  tar cvz "$@" | openssl aes-256-cbc -salt -pass "pass:$pass"
else
  tar cvz "$@" | openssl aes-256-cbc -salt -pass "pass:$pass" > $output
fi
