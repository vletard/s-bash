#!/bin/bash

# Décrypte l'ensemble des fichiers fournis en argument vers la sortie standard
# Le décryptage est symétrique à l'encryption de pack.sh et utilise la clé publique rsa dans ~/.ssh/

################ Example found in /usr/share/doc/util-linux/examples/getopt-parse.bash

TEMP=`getopt -o l --long list -n "$0" -- "$@"`

if [ $? != 0 ] ; then echo "Abandon" >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

while true ; do
	case "$1" in
		-l|--list)
			openssl aes-256-cbc -d -pass file:$HOME/.ssh/id_rsa.pub | tar tz
			exit $? ;;
		--) shift ; break ;;
		*) echo "Internal error!" ; exit 1 ;;
	esac
done

################ End example ##########################################################

if (( $# > 0 ))
then
  cat $1 | openssl aes-256-cbc -d -pass file:$HOME/.ssh/id_rsa.pub | tar xvz
else
  openssl aes-256-cbc -d -pass file:$HOME/.ssh/id_rsa.pub | tar xvz
fi
