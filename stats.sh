#!/bin/bash

if (( $# == 0 ))
then
  R -q -e "x <- read.csv('stdin', header = F); summary(x); cat(sprintf(' StDev  :%f\n Length :%d\n', sd(x[ , 1]), length(x[, 1])))"
else
  R -q -e "x <- read.csv('$1', header = F); summary(x); cat(sprintf(' StDev  :%f\n Length :%d\n', sd(x[ , 1]), length(x[, 1])))"
fi
