#!/bin/bash

# Recursively encrypts the files given in argument to stdout

pass=
output=
compat="-md sha256"
self=false
comm=cvz

set -eo pipefail

################ Example found in /usr/share/doc/util-linux/examples/getopt-parse.bash

TEMP=`getopt -o hvqo: --long help,quiet,verbose    -n "$0" -- "$@"`

if [ $? != 0 ] ; then echo "Abandon" >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

while true ; do
  case "$1" in
    -o)
      output=$2
      shift 2 ;;
    -q|--quiet)
      comm=cz
      shift ;;
    -v|--verbose)
      comm=cvz
      shift ;;
    -h|--help)
      shift $# ; break ;;
    --) shift ; break ;;
    *) echo "Internal error!" >&2 ; exit 1 ;;
  esac
done

################ End example ##########################################################

if (( $# < 1 )) || [ -z "$output" ]
then
  printf "Usage: %s [-f PASS_FILE] [-l] -o OUTPUT_FILE FILE[S]\n" "$0" >&2
  printf "\nOptions:\n" >&2
  printf "   -o                  encrypts the FILES into OUTPUT_FILE (this argument is mandatory)\n" >&2
  printf "   -q, --quiet         runs silently\n" >&2
  printf "   -v, --verbose       prints every encrypted filename (this is default)\n" >&2
  printf "   -h, --help          prints this message\n" >&2
  exit 1
fi

touch $output
export passwd=""

while test -z $passwd
do
  read -sp "Enter password: " passwd
  echo >&2
  read -sp "Repeat password: " confirm
  if [ "$passwd" != "$confirm" ]
  then
    echo "Confirmation failed." >&2
    passwd=""
  fi
done

tar $comm "$@" | openssl aes-256-cbc -pass env:passwd -pbkdf2 -salt $compat | cat $(which unpack.sh) - > $output

chmod u+x $output
