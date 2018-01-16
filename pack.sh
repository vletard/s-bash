#!/bin/bash

# Recursively encrypts the files given in argument to stdout

pass=
output=
compat="-md sha256"
self=false
comm=cvz

################ Example found in /usr/share/doc/util-linux/examples/getopt-parse.bash

TEMP=`getopt -o hvqo:s --long help,quiet,verbose,self-extract    -n "$0" -- "$@"`

if [ $? != 0 ] ; then echo "Abandon" >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

while true ; do
  case "$1" in
    -s|--self-extract)
      self=true
      shift ;;
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
    *) echo "Internal error!" ; exit 1 ;;
  esac
done

################ End example ##########################################################

if (( $# < 1 ))
then
  printf "Usage: %s [-f PASS_FILE] [-l] [-o OUTPUT_FILE] FILE[S]\n" "$0" >&2
  printf "\nOptions:\n" >&2
  printf "   -o                  encrypts the FILES into OUTPUT_FILE instead of stdout\n" >&2
  printf "   -s, --self-extract  makes the produced file a self extractible bash binary\n" >&2
  printf "                       simply execute the produced file to unpack            \n" >&2
  printf "   -q, --quiet         runs silently\n" >&2
  printf "   -v, --verbose       prints every encrypted filename (this is default)\n" >&2
  printf "   -h, --help          prints this message\n" >&2
  exit 1
fi

export passwd=""

while test -z $passwd
do
  read -sp "Enter password: " passwd
  echo
  read -sp "Repeat password: " confirm
  if [ "$passwd" != "$confirm" ]
  then
    echo "Confirmation failed."
    passwd=""
  fi
done

tar $comm "$@" | openssl aes-256-cbc -pass env:passwd -salt $compat | if $self
then
  cat $(which unpack.sh) -
else
  cat
fi | if test -z "$output"
then
  cat
else
  cat > $output
fi
if $self
then
  chmod u+x $output
fi
