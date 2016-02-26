#!/bin/bash

# Déchiffre chaque fichier fourni en argument
# Le déchiffrage est asymétrique et cherche parmi les clés privées gpg disponibles

if (( $# == 0 ))
then
    gpg --decrypt | tar xvz
else
  for f in $*
  do
    gpg --decrypt $f | tar xvz
  done
fi
