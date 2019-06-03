#!/usr/bin/env bash

# while IFS='' read -r projectname || [[ -n "$projectname" ]]; do

while read -r projectname && [[ -n $projectname ]]; do

runningprocess=$(ps aux | grep rsync | grep $projectname)

if [[ $runningprocess = "" ]]; then

  projectyear=$(echo "$projectname" | sed 's/^.*_p//;s/[0-9]\{5\}$//')

  if [[ "$projectname" = PHILIPS*_p* ]]; then
    freyapath="/Volumes/FREYA/PROJECTS/philips"
    hqpath="/Volumes/HEIMDALL/PROJECTS/philips"
  elif [[ "$projectname" = BOOKING*_p* ]]; then
    freyapath="/Volumes/FREYA/PROJECTS/booking"
    hqpath="/Volumes/HEIMDALL/PROJECTS/booking"
  else
    freyapath="/Volumes/FREYA/PROJECTS/p$projectyear"
    hqpath="/Volumes/HEIMDALL/PROJECTS/p$projectyear"
  fi

  # # # # # # # # # # # #
  #       PROJECTS      #
  # # # # # # # # # # # #

  echo "Syncing Project from $hqpath/$projectname" to "$freyapath/$projectname"
  rsync -Pazvvvh --no-p -f"- .*" -f"- @*" "$hqpath/$projectname" "$freyapath/"

  echo "Syncing from $freyapath/$projectname" to "$hqpath/$projectname"
  rsync -Pazvvvh --no-p -f"- .*" -f"- @*" "$freyapath/$projectname" "$hqpath/"

  # # # # # # # # # # # #
  #     FLAME ARCHS     #
  # # # # # # # # # # # #

  if [[ -d /HAMMER/FLAME-ARCHIVES/TO-NY/$projectname ]]; then
    echo "Syncing Flame Archives from /HAMMER/FLAME-ARCHIVES/TO-NY/$projectname to /FREYA/FLAME/FROM_HQ"
    cp -a /HAMMER/FLAME-ARCHIVES/TO-NY/$projectname vtr@10.0.20.10:/volume1/FREYA/FLAME/FROM_HQ/
  fi

  if [[ -d /FREYA/FLAME/TO_HQ/$projectname ]]; then
    echo "Syncing Flame Archives from /FREYA/FLAME/TO_HQ/$projectname to /HAMMER/FLAME-ARCHIVES/FROM-NY/"
    cp -a vtr@10.0.20.10:/volume1/FREYA/FLAME/TO_HQ/$projectname /HAMMER/FLAME-ARCHIVES/FROM-NY/
  fi

  # # # # # # # # # # # #
  #     SYNC FINALS     #
  # # # # # # # # # # # #

  # if [[ "$projectyear" != 18 ]]; then
  #   if [[ -d vtr@10.0.20.10:/volume1/FREYA/FINALS/p"$projectyear"/"$projectname" ]] && [[ -d /ODIN/LIBRARY/pFINALS/p"$projectyear"/"$projectname" ]]; then
  #     rsync -Pazvh --no-p -f"- .*" -f"- @*" vtr@10.0.20.10:/volume1/FREYA/FINALS/p"$projectyear"/"$projectname" /ODIN/LIBRARY/pFINALS/p"$projectyear"/
  #   fi
  # else
  #   if [[ -d vtr@10.0.20.10:/volume1/FREYA/FINALS/p"$projectyear"/"$projectname" ]] && [[ -d /ODIN/LIBRARY/pFINALS/p"$projectyear"/"$projectname" ]]; then
  #     rsync -Pazvh --no-p -f"- .*" -f"- @*" vtr@10.0.20.10:/volume1/FREYA/FINALS/p"$projectyear"/"$projectname" /ODIN/LIBRARY/pFINALS/p"$projectyear"/
  #   fi
  # fi

fi

done < /AMBASSADORS_SHARED/STUDIO/sync-to-nyc.txt
