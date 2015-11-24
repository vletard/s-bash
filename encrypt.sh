#!/bin/bash

# Encrypte l'ensemble des fichiers fournis en argument vers la sortie standard
# L'encryption est asymétrique et utilise la clé publique rsa donnée en argument

recipient=

################ Example found in /usr/share/doc/util-linux/examples/getopt-parse.bash

TEMP=`getopt -o k: --long recipient-key: -n "$0" -- "$@"`

if [ $? != 0 ] ; then echo "Abandon" >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

while true ; do
	case "$1" in
		-k|--recipient-key) recipient=$2 ; shift 2 ;;
		--) shift ; break ;;
		*) echo "Internal error!" ; exit 1 ;;
	esac
done

if [ "$recipient" == "" ]
then
  echo -e "Usage: $0 -k RECIPIENT_PUBLIC_KEY FILE[S]\n" >&2
  exit 1
fi

################ End example ##########################################################

echo "Attention, sortie standard utilisée pour écrire l'archive !" >&2
sleep 7
sym_key=$(mktemp ./tmp.XXXXXXXX)
head -c 64 < /dev/urandom > $sym_key
dir=$(mktemp -d ./tmp.XXXXXXXX)
dirname=$(echo $dir | rev | cut -f 1 -d "/" | rev)
tar cvz "$@" | openssl aes-256-cbc -salt -pass file:$sym_key > $dir/data
openssl rsautl -encrypt -pubin -inkey $recipient < $sym_key > $dir/enc
rm -f $sym_key
cd /tmp/
tar cvz $dirname 2> /dev/null
rm -Rf $dir
