#!/bin/bash

if ! which R > /dev/null
then
  printf "%s requires R to be installed.\naborting.\n" "$0" >&2
  exit 1
fi

if (( $# == 0 ))
then
  R -q -e "x <- read.csv('stdin', header = F); summary(x); cat(sprintf(' StDev  :%f\n Length :%d\n   Sum  :%f\n', sd(x[ , 1]), length(x[, 1]), sum(x[,1])))"
else
  R -q -e "x <- read.csv('$1', header = F); summary(x); cat(sprintf(' StDev  :%f\n Length :%d\n   Sum  :%f\n', sd(x[ , 1]), length(x[, 1]), sum(x[,1])))"
fi
