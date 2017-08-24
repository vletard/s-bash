#!/bin/bash

# Decrypts the file provided in argument (or stdin) and unpacks its contents

pass=

if (( $# != 1 ))
then
  printf "Usage: %s ENCRYPTED_FILE\n" "$0" >&2
  exit 1
fi

################ Example found in /usr/share/doc/util-linux/examples/getopt-parse.bash

TEMP=`getopt -o lf: --long list,key-file: -n "$0" -- "$@"`

if [ $? != 0 ] ; then echo "Abandon" >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

while true ; do
  case "$1" in
    -f|--key-file)     
      pass=$(tr -d '\\n' < $2)
      shift 2 ;;
    -l|--list)
      openssl aes-256-cbc -d -pass "pass:$pass" | tar tz
      exit $? ;;
    --) shift ; break ;;
    *) echo "Internal error!" ; exit 1 ;;
  esac
done

################ End example ##########################################################

if [ "$pass" = "" ]
then
  printf "Enter passphrase: "
  read -s pass
  printf "\n\n"
fi

cat $1 | openssl aes-256-cbc -d -pass "pass:$pass" | tar xvz
