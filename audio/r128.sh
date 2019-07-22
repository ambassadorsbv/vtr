#!/usr/bin/env bash
IFS=$'\n'

if [[ -f $1 ]]; then
  flist="$1";
elif [[ -d $1 ]]; then
  flist=$(find $1 -type f -not -iname ".*" -and -iname "*.mov" -or -iname "*.wav" -or -iname "*.aif*" -or -iname "*.mp4" -or -iname "*.mxf" -or -iname "*.webm" -or -iname "*.wmv" -or -iname "*.mkv" -or -iname "*.avi" -or -iname "*.flv")
fi

for f in $flist ; do
  if [[ -f $f ]]; then
    echo "Probing loudness of \"$(basename $f)\""
    ffprobe -f lavfi amovie="$f",ebur128=metadata=1 -show_frames 2>&1 | grep "I:";
  fi;
done;