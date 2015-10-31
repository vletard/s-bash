#!/bin/bash

# Décrypte l'ensemble des fichiers fournis en argument vers la sortie standard
# Le décryptage est asymétrique et utilise la privée rsa par défaut

dir=$(mktemp -d)
wd=$(pwd)

for f in $*
do
  tar xvf $f -C $dir > /dev/null
  cd $dir
  subdir=$(ls)
  openssl rsautl -decrypt -inkey ~/.ssh/id_rsa < $subdir/enc > $subdir/key
  cd $wd
  openssl aes-256-cbc -d -pass file:$dir/$subdir/key < $dir/$subdir/data | tar xvz
  rm -Rvf $dir/$subdir/
done

rmdir -v $dir
