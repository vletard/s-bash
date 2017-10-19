#!/bin/bash

# Decrypts the file provided in argument (or stdin) and unpacks its contents

pass=
comm=xvz
compat="-md sha256"
help=false

################ Example found in /usr/share/doc/util-linux/examples/getopt-parse.bash

TEMP=`getopt -o lh --long list,help -n "$0" -- "$@"`

if [ $? != 0 ] ; then echo "Abandon" >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

while true ; do
  case "$1" in
    -l|--list)
      comm=tz
      shift ;;
    -h|--help)
      help=true; shift; break ;;
    --) shift ; break ;;
    *) echo "Internal error!" ; exit 1 ;;
  esac
done

################ End example ##########################################################

if $help
then
  printf "Usage: %s ENCRYPTED_FILE [-f PASS_FILE] [-l]\n" "$0" >&2
  printf "\nOptions:\n" >&2
  printf "   -l, --list          lists the contents of the encrypted file rather than extracting it\n" >&2
  printf "   -h, --help          prints this message\n" >&2
  exit 1
fi

if (( $# > 0 ))
then
  openssl aes-256-cbc $compat -d -in $1 | tar $comm
else
  skipping_lines=$(grep -anm1 "^__END_SCRIPT__$" < $0 | cut -f 1 -d ':')
  openssl aes-256-cbc $compat -d -in <(tail -n +$((skipping_lines + 1)) < $0) | tar $comm
fi

exit $?

__END_SCRIPT__
