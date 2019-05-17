#!/usr/bin/env bash

if [[ -f $1 ]]; then
  flist="$1" ;
elif [[ -d $1 ]]; then
  flist=$(find "$1" -type f -iname "*.wav" -or -iname "*.mxf" -or -iname "*.mov" -or -iname "*.mp4" -or -iname "*.mkv" -or -iname "*.avi" -or -iname "*.flv" -or -iname "*.webm" -or -iname "*.aif*")
fi

for f in $flist ; do
  if [[ -f $f ]]; then
    IFS=$'\n' basename "$f" && ffprobe -f lavfi amovie="$f",ebur128=metadata=1 -show_frames 2>&1 | grep "I:";
  fi;
done;