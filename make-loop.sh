#!/bin/bash

while sleep 7
do
  make -s $* || notify-send "make error"
done
