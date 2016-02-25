#!/bin/bash

# Chiffre l'ensemble des fichiers fournis en argument vers la sortie standard
# Le chiffrement est asymétrique et utilise la clé publique rsa donnée en argument

recipient=

################ Example found in /usr/share/doc/util-linux/examples/getopt-parse.bash

TEMP=`getopt -o r: --long recipient: -n "$0" -- "$@"`

if [ $? != 0 ] ; then echo "Abandon" >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

while true ; do
	case "$1" in
		-r|--recipient) recipient=$2 ; shift 2 ;;
		--) shift ; break ;;
		*) echo "Internal error!" ; exit 1 ;;
	esac
done

if [ "$recipient" == "" ]
then
  echo -e "Usage: $0 -r RECIPIENT FILE[S]\n" >&2
  exit 1
fi

################ End example ##########################################################

echo "Attention, sortie standard utilisée pour écrire le fichier chiffré !" >&2
sleep 7
stdbuf -eL tar cvz "$@" | gpg -v --encrypt -r $recipient
