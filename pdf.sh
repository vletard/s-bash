#!/bin/bash

file=$(mktemp)
unoconv -o $file "$1"
mimeopen $file
rm -f $file
