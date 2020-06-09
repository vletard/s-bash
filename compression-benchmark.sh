#!/bin/bash

# This is a very simple compression benchmark
# Usage: compression-benchmark.sh some files or directories to compress

if ! which xz lzma gzip bzip2 lrzip
then
  echo "Some compression binaries are missing." >&2
  exit 1
fi

for input in "$*"
do
  for method in xz lzma gzip bzip2
  do
    tar c "$input" > "${input}".tar
    $method "${input}".tar
  done

  tar c "$input" > "${input}".tar
  lrzip -z "${input}".tar

  du -sh "${input}".tar* | sort -h
done
