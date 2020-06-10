#!/bin/bash

# This is a very simple compression benchmark
# Usage: compression-benchmark.sh some files or directories to compress

if ! which xz lzma gzip bzip2 lrzip
then
  echo "Some compression binaries are missing." >&2
  exit 1
fi

for input in "$@"
do
  input=${input%/}
  for method in xz lzma gzip bzip2
  do
    tar c "$input" > "${input}".tar
    $method "${input}".tar
  done

  tar c "$input" > "${input}".tar
  lrzip -z -p 1 "${input}".tar

  du -sh "${input}".tar* | sort -h
done
