#!/bin/bash

# Déchiffre chaque fichier fourni en argument
# Le déchiffrage est asymétrique et cherche parmi les clés privées gpg disponibles

for f in $*
do
  gpg --decrypt $f | tar xvz
done
