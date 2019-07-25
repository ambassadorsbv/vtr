#!/usr/bin/env bash
IFS=$'\n'

if [[ -f $1 ]]; then
  flist="$1";
elif [[ -d $1 ]]; then
  flist=$(find -E "$1" -type f ! -iname ".*" -regex '.*\.(mov|mp4|mxf|mkv|avi|wmv|webm|flv|mp3|wav|aif?)')
fi

for f in $flist ; do
  if [[ -f $f ]]; then
    echo "Probing loudness of \"$(basename $f)\""
    ffprobe -f lavfi amovie="$f",ebur128=metadata=1 -show_frames 2>&1 | grep "I:";
  fi;
done;