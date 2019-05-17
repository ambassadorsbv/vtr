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

# if [[ -f "$1" ]]; then
#   filelist="$1";
# elif [[ -d "$1" ]]; then
#   IFS='\n'
#   filelist=$(ls "$1"/*.{wav,mxf,aif,aiff,mov,mp4,mkv,avi,flv,webm});
# fi;
#
# for f in $filelist; do
#   if [[ -f "$f" ]]; then
#   echo "$f"
#   ffprobe -f lavfi amovie="$f",ebur128=metadata=1 -show_frames 2>&1 | grep "I:";
#   fi;
# done
