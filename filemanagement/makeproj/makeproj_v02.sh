#!/usr/bin/env bash
today=$(date +%Y%m%d)
SCRIPTFOLDER=/HEIMDALL/LIBRARY/studio/scripts/vtr/filemanagement/makeproj

makefolders() {
  mkdir -p "$projectpath"/01_share/
  mkdir -p "$projectpath"/01_share/{interal,external}

  mkdir -p "$projectpath"/01_share/internal/{cube,edl,art,sound}
  mkdir -p "$projectpath"/01_share/internal/cube/
  mkdir -p "$projectpath"/01_share/internal/edl/
  mkdir -p "$projectpath"/01_share/internal/art/{screengrabs,titles}
  mkdir -p "$projectpath"/01_share/internal/sound/{wip,omf}

  mkdir -p "$projectpath"/01_share/external/{edl,art,mov,docs}
  mkdir -p "$projectpath"/01_share/external/art/{logo,titles,fonts}
  mkdir -p "$projectpath"/01_share/external/edl/{sound,video}
  mkdir -p "$projectpath"/01_share/external/mov/{ref,master,compshots,graded}
  mkdir -p "$projectpath"/01_share/external/docs/{deliveryspecs,subs,copy,camerareports}

  mkdir -p "$projectpath"/02_work
  mkdir -p "$projectpath"/02_work/{aefx,maya,nuke,premiere,photoshop,shotgun,pr,renders}
  mkdir -p "$projectpath"/02_work/renders/{maya,nuke,baselight,premiere,plates,tracking,dailies/$today,reference}

  mkdir -p "$projectpath"/03_final
  mkdir -p "$projectpath"/03_final/video/{masters,relay}
  mkdir -p "$projectpath"/03_final/sound

  mkdir -p "$projectpath"/04_archive
  mkdir -p "$projectpath"/04_archive/{flame,baselight}
}

makephilips() {
  mkdir -p "$projectpath"/01_share/external/art/{CAD,PGD,MUS}
  mkdir -p "$projectpath"/01_share/external/docs/{briefs,feedback,asset_matrix}
}

runsnacl() {
  # User the permissions lists to set the right permissions for folders, using the SN-ACL program. This was copied over from the server itself, and is a proprietary software! If it ever gets lost on this machine, make sure to copy it over from the server again. (Should be in /bin/snacl)
  /usr/local/bin/snacl -ER "$projectpath"/* < "$permissionsdir"/subfolder_permissions.snacl # sets permissions for subfolders inside a project's division folders
  /usr/local/bin/snacl -ER "$projectpath"/**/*.* < "$permissionsdir"/file_permissions.snacl # sets permissions for subfolders inside a project's division folders
  /usr/local/bin/snacl -ER "$projectpath"/vfx/* < "$permissionsdir"/producer_permissions.snacl # removes write permissions for Producers in VFX folders
  /usr/local/bin/snacl -E "$projectpath"/* < "$permissionsdir"/folder_permissions.snacl # sets division folders permissions in the Project
  /usr/local/bin/snacl -E "$projectpath" < "$permissionsdir"/toplevel_permissions.snacl # sets toplevel permissions for the Project
}

inputs() {
  echo "Project name and number not read."
  echo "Please enter project name."
  read proj_input
  echo "Please enter project number."
  read num_input
}

lencheck() {
  if [[ ${#projectfolder} -gt 32 ]]; then
    echo "Name $projectfolder exceeds maximum character length for project naming."
    echo "Your projectname had a length of ${#projectfolder} characters."
    echo "Please specify a new name under 32 characters."
    makeproj
  fi
}

makeproj() {

  # you can input the project name directly into this function. If you don't, it'll ask for the project details.
  if [[ $1 ]] && [[ $2 ]]; then
    proj_input="$1"
    num_input="$2"
  else
    inputs
  fi

  # remove all the special characters except [[ ]] and ', then changes whitespaces to -, then changes all lowercase letters to uppercase using sed.
  projectname=$(echo "$proj_input" | sed 's/±§!@#$%^&*()=+_{};:|,.<>\?//g;s/\ /-/g' | tr '[:lower:]' '[:upper:]')

  # is this a philips or a booking project? If so, we set a flag and strip the client name from the project.
  philipscheck=$(echo "$projectname" | grep PHILIPS)
  bookingcheck=$(echo "$projectname" | grep BOOKING)
  if [[ -z $philipscheck ]]; then
    isphilips="1"
    projectname="${projectname/PHILIPS_/}"
  fi
  if [[ -z $bookingcheck ]]; then
    isbooking="1"
    projectname="${projectname/BOOKING_/}"
  fi

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

  # when the projectname and number check out, combine those into the full project folder name.
  projectfolder="$projectname"_"$projectnumber"

  # then we check if the project folder name does not exceed the amount of characters set (32) for shotgun to handle
  lencheck

  # now we check where the project should be created, in booking, philips or sorted by year.
  if [[ $isphilips == "1" ]]; then
    projectpath="/HEIMDALL/PROJECTS/philips/$projectfolder"
  elif [[ $isbooking == "1" ]]; then
    projectpath="/HEIMDALL/PROJECTS/booking/$projectfolder"
  else
    projectpath="/HEIMDALL/PROJECTS/$projectyear/$projectfolder"
  fi

  # if the year folder does not exist, we'll need a higherup (VTR or IT) to create it before creating the project folder.
  # if it does exist, we can create the main project folder.
  if [[ ! -d /HEIMDALL/PROJECTS/$projectyear/ ]]; then
    echo "$projectyear folder does not exist, please have an admin create the folder. Exiting."
    exit 1
  elif [[ ! -d $projectpath ]]; then
    mkdir -p "$projectpath"
    cd "$projectpath" || exit 1
  elif [[ -d $projectpath ]]; then
    echo "Project folder already exists at $projectpath, exiting."
    exit 1
  else
    echo "Could not jump to $projectpath. Please check path."
    exit 1
  fi

  # now we can see if we're in the right project folder, and start creating subfolders.
  # if the project is a philips project, it'll need a few extra folders.
  if [[ $PWD == "$projectpath" ]]; then
    makefolders
    if [[ $isphilips == "1" ]]; then
      makephilips
    fi
  fi

  # next, we set the right folder permissions.
  # we try to read the permission files from the Heimdall library first, as that is the most likely to be up-to-date (being a git repo). Else, fall back to the local folder.
  permissionsdir="$SCRIPTFOLDER"/permissions/
  if [[ ! -d $permissionsdir ]]; then
    permissionsdir=/home/admin/Documents/makeproj/permissions/
    # this home folder is located on the Archiware / p5 server!
  fi

#    runsnacl

  echo "Project created on" "$today" "as" "$projectname""_""$projectnumber"
  echo "Project created on" "$today" "as" "$projectname""_""$projectnumber" >> "$SCRIPTFOLDER"/project_history.log
}

## THIS IS WHERE WE START CREATING A PROJECT.
## RUN THE SCRIPT AND ADD THE PROJECT NAME, FOLLOWED BY THE PROJECT NUMBER TO CREATE A PROJECT DIRECTLY.

if [[ -z $1 ]]; then
  echo "First variable not set."
  echo "Would you like to create a project, or reset a projects' permissions and rights?"
  select projsnacl in "Project" "Rights"; do
    case $projsnacl in
      Project ) makeproj
                break;;
      Rights ) inputs;
               runsnacl;
               break;;
    esac
  done
elif [[ $1 ]] && [[ $2 ]]; then
  makeproj
fi
