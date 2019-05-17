#!/bin/bash
IFS=$'\n'

zipdir="$1"
dest=$(echo "$1" | sed 's:\/$::')
sstring="$2"
debug="$3"

function makezip() {
  mkdir -p "$dest"/"$basedirdest"/
  echo "Zipping $count files in $zipfolder, please wait..."
  zip -jq1 "$output".zip $filelist
}

function makeref() {
  ffmpeg -hide_banner -loglevel panic -pattern_type glob \
  -y -i "$zipfolder/*.$sstring" -c:v libx264 -b:v 5000k \
  -pix_fmt yuv420p -r 25 -f mp4 "$output.mp4"
}

# if [[ ! "$debug" = false ]] ; then
#   echo ""
#   echo "Debug mode on. Checking for folders to zip, please wait..."
#   echo ""
# fi

if [[ -z "$zipdir" ]] && [[ -z "$dest" ]]; then
  echo "Variables not set. Please input"
  echo "1: Input folder"
  echo "2: Search string"
  echo "3: Debug mode - input 'false' to run live mode"
else

  zipfolders=$(find "$zipdir" -depth -type d)

  for zipfolder in $zipfolders; do
    filelist=$(find "$zipfolder" -mindepth 1 -maxdepth 1 -type f -and -iname "*$sstring*" -and -not -iname ".*" -and -not -iname "*.zip")
    count=$(echo "$filelist" | wc -l)

    basedest=$(basename "$zipfolder")
    dirdest=$(dirname "$zipfolder")
    basedirdest=$(basename "$dirdest")
    output="$dest"/"$basedirdest"/"$basedirdest"_360_"$basedest"
    outfilename=$(basename "$output")

# In debug mode, we'll list all the variables and then exit
    if [[ ! "$debug" = false ]] ; then
      echo "Running in debug mode. Input argument 'false' to run live mode."
      echo " "
      echo "Variables set to:"
      echo "basedest = $basedest"
      echo "dirdest = $dirdest"
      echo "basedirdest = $basedirdest"
      echo "full output path will be $output.zip"
      echo " "
      echo "Will archive $count files in $zipfolder that contain the string $sstring"
      echo "And create a reference file at $output.mp4"
      exit 1
    else

  # We only want to run this whole part if there's more than one
  # image in the source folder. So, let's wrap this in a test clause:
      if [[ "$count" -gt 1 ]]; then

  # If we're running live mode, this is the part that creates the zip.
        if [[ -f $output.zip ]]; then
          echo "Zip file $outfilename.zip already exists."
          echo "Overwrite? (y/n)"
          select yn in "Yes" "No"; do
              case $yn in
                Yes )
            			echo "Removing old zipfile and creating new version."
            			rm -f "$output".zip
                  makezip
                  break
                  continue;;
                No )
            			echo "Skipping zip file creation for $outfilename"
            			break
            			continue;;
              esac
          done
        else
            makezip
        fi
  # Error handling if there was a problem creating the zip file.
        if [[ -f $output.zip ]]; then
          echo "Zip of $zipfolder completed!"
          echo "The file can be found at $output.zip"
        else
          echo "Zip error, please run in debug mode."
          exit 1
        fi
        echo " "

  # This is the part where we make the ref video, if the search string was a supported image format.
        if [[ $sstring = png ]] || [[ $sstring = dpx ]] || [[ $sstring = exr ]] || [[ $sstring = tif* ]] || [[ $sstring = jp*g ]]; then
          if [[ -f $output.mp4 ]]; then
            echo "A reference video for this zip already existst."
            echo "Overwrite? (y/n)"
            select yn in "Yes" "No"; do
              case $yn in
                Yes ) makeref
                      break
                      continue;;
                No )  echo "Not creating reference file. Stopping jobs."
                			break
                			exit 1
              esac
            done
          elif [[ ! -f $output.mp4 ]]; then
            echo "Creating reference file for $outfilename."
            echo " "
            makeref
          fi
        else
          echo "$sstring does not indicate a supported image sequence."
          echo "Can not create reference video."
        fi
  # Let the user know what happened with that ref video.
        if [[ -f $output.mp4 ]]; then
      	  echo "Reference file located at $output.mp4"
      	else
      	  echo "Error creating reference file. Please run in debug mode."
      	  exit 1
      	fi
      fi
    fi
    echo " "
  done
fi
