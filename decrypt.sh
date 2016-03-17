#!/bin/bash

# Déchiffre chaque fichier fourni en argument
# Le déchiffrage est asymétrique et cherche parmi les clés privées gpg disponibles

tar_cmd=xvz

################ Example found in /usr/share/doc/util-linux/examples/getopt-parse.bash

TEMP=`getopt -o l --long list -n "$0" -- "$@"`

if [ $? != 0 ] ; then echo "Abandon" >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

while true ; do
  case "$1" in
    -l|--list)
      tar_cmd=tz
      shift ;;
  --) shift ; break ;;
  *) echo "Internal error!" ; exit 1 ;;
  esac
done

################ End example ##########################################################


if (( $# == 0 ))
then
    gpg --decrypt | tar $tar_cmd
else
  for f in $*
  do
    gpg --decrypt $f | tar $tar_cmd
  done
fi
