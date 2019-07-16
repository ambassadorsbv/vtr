#!/usr/bin/env bash
today=$(date +%Y%m%d)

runsnacl() {    # User the permissions lists to set the right permissions for folders, using the SN-ACL program. This was copied over from the server itself, and is a proprietary software! If it ever gets lost on this machine, make sure to copy it over from the server again. (Should be in /bin/snacl)
                /usr/local/bin/snacl -ER "$projectpath"/* < "$permissionsdir"/subfolder_permissions.snacl # sets permissions for subfolders inside a project's division folders
                /usr/local/bin/snacl -ER "$projectpath"/**/*.* < "$permissionsdir"/file_permissions.snacl # sets permissions for subfolders inside a project's division folders
                /usr/local/bin/snacl -ER "$projectpath"/vfx/* < "$permissionsdir"/producer_permissions.snacl # removes write permissions for Producers in VFX folders
                /usr/local/bin/snacl -E "$projectpath"/* < "$permissionsdir"/folder_permissions.snacl # sets division folders permissions in the Project
                /usr/local/bin/snacl -E "$projectpath" < "$permissionsdir"/toplevel_permissions.snacl # sets toplevel permissions for the Project
}

if [[ -z $1 ]]; then
  echo "First variable not set."
#  echo "1. Project name as in FW"
#  echo "2. Project number"
#  echo ""
  echo "Please enter project name."
  read proj_input
  echo "Please enter project number."
  read num_input
fi

if [[ -z $2 ]]; then
  echo "Second variable not set."
  echo "Please enter project number."
  read num_input
fi

# remove all the special characters except [[ ]] and ', then changes whitespaces to -, then changes all lowercase letters to uppercase using sed.
if [[ $1 ]]; then
  proj_input="$1"
fi

projectname=$(echo "$proj_input" | sed 's/±§!@#$%^&*()=+_{};:|,.<>\?//g;s/\ /-/g' | tr '[:lower:]' '[:upper:]')

# strip the p from the second input in case someone gave a p with the projectnumber.
# then we check if the string contains only numbers, starting with 1 or 2, and is exactly 7 characters long.
# if both of these are true, the projectnumber is valid and can be used as a projectnumber.
if [[ $2 ]]; then
  num_input="$2"
fi

projectnumber="${num_input/p/}"
re='^[1|2][0-9]+$'
if [[ ! $projectnumber ]]; then
  echo "No projectnumber specified."
  exit 1
elif [[ ! $projectnumber =~ $re ]] || [[ ${#projectnumber} != 7 ]];  then
  echo "Error: projectnumber ($projectnumber) not valid, exiting."
  exit 1
else
  # use only the year, not the whole number, then add the p for project.
  projectyear=p$(echo "$projectnumber" | cut -c-2)
  projectnumber=p"$projectnumber"
fi

# when the projectname and number check out, create the full project folder path.
# then we check if the project folder name does not exceed the amount of characters set (36) for shotgun to handle
if [[ ! -d /HEIMDALL/PROJECTS/$projectyear/ ]]; then
  echo "$projectyear folder does not exist, please have an admin create the folder. Exiting."
  exit 1
else
  projectfolder="$projectname"_"$projectnumber"
  projectpath="/HEIMDALL/PROJECTS/$projectyear/$projectfolder"
fi

if [[ ${#projectfolder} -gt 32 ]]; then
  echo "Name $projectfolder exceeds maximum character length for project naming."
  echo "Your projectname had a length of ${#projectfolder} characters."
  echo "Please specify a new name under 32 characters."
  exit 1
else
  if [[ ! -d $projectpath ]]; then
    mkdir -p "$projectpath"
    cd "$projectpath" || exit 1
  elif [[ -d $projectpath ]]; then
    echo "Project folder already exists at $projectpath, exiting."
    exit 1
  fi
fi

# Creating subfolders inside the project per department. I've spliced this into seperate commands to keep the script legible, and make it easier to adjust a (sub)folder structure for just one department.
if [[ $PWD == "$projectpath" ]]; then
  mkdir -p "$projectpath"/{baselight,dailies,edit,flame,share,sound,vfx,finals}

  mkdir -p "$projectpath"/baselight/{archive,blg,exports}

  mkdir -p "$projectpath"/dailies/"$today"

  mkdir -p "$projectpath"/flame/{archive,publish}

  mkdir -p "$projectpath"/pr/{docs,mov,stills}

  mkdir -p "$projectpath"/edit/00_docs/{01_scripts,02_storyboard,03_LUT}
  mkdir -p "$projectpath"/edit/01_projects/{01_premiere,02_AE,03_AVID}
  mkdir -p "$projectpath"/edit/02_footage/{01_proxies,02_delivered,03_searched}
  mkdir -p "$projectpath"/edit/03_artwork/{01_fonts,02_logos,03_graphics,04_titles}
  mkdir -p "$projectpath"/edit/04_audio/{01_guides,02_music,03_effects,04_voiceover,05_mix}
  mkdir -p "$projectpath"/edit/05_exports/{01_preview,02_clean,03_approved,04_refs,05_edl,06_dnxhd,07_omf}

  mkdir -p "$projectpath"/share/{artwork,docs,edl,mov}
  mkdir -p "$projectpath"/share/artwork/{external/{fonts,logo,graphics},internal/{screengrabs,graphics}}
  mkdir -p "$projectpath"/share/docs/{camerareports,copy,deliveryspecs,subs}
  mkdir -p "$projectpath"/share/edl/{external,internal}
  mkdir -p "$projectpath"/share/projectfiles/{aefx,premiere}
  mkdir -p "$projectpath"/share/mov/{external/{compshots,graded,offline,stock},internal/{for_cube,for_sound,offline_approved}}

  mkdir -p "$projectpath"/sound/{external/{omf,wav},internal/{mix,wip,omf}}

  mkdir -p "$projectpath"/vfx/{_exchange,Houdini,PFTrack,_RENDERS/{cg,comp,aefx},_plates,_reference,aefx,illustrator,inDesign,mari,maya,nuke,photoshop,realflow,shotgun,zbrush}

    permissionsdir=/HEIMDALL/LIBRARY/studio/makeproj/
  if [[ ! -d $permissionsdir ]]; then
    permissionsdir=/home/admin/Documents/makeproj/
    # this home folder is located on the Archiware / p5 server!
  fi

  runsnacl

else
  echo "Could not cd to $projectpath. Please check path."
  exit 1
fi

echo "Project created on" "$today" "as" "$projectname""_""$projectnumber"
echo "Project created on" "$today" "as" "$projectname""_""$projectnumber" >> /HEIMDALL/LIBRARY/studio/makeproj/project_history.log
