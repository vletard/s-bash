#!/bin/bash

if ! which unoconv > /dev/null
then
  notify-send "$0: unoconv was not found"
  exit 1
else
  file=$(mktemp)
  unoconv -o $file "$1"
  mimeopen -n $file
  rm -f $file
fi
