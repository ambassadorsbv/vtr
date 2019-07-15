#!/usr/bin/env bash

runsnacl() { # User the permissions lists to set the right permissions for folders, using the SN-ACL program. This was copied over from the server itself, and is a proprietary software! If it ever gets lost on this machine, make sure to copy it over from the server again. (Should be in /bin/snacl)
  echo "Setting permissions on subfolders."
             /usr/local/bin/snacl -ER "$projectpath"/* < "$permissionsdir"/subfolder_permissions.snacl # sets permissions for subfolders inside a project's division folders
  echo "Setting permissions vfx specific folders."
             /usr/local/bin/snacl -ER "$projectpath"/vfx/{_RENDERS,shotgun} < "$permissionsdir"/producer_permissions.snacl # removes write permissions for Producers in VFX folders
  echo "Setting permissions on project division folders."
             /usr/local/bin/snacl -E "$projectpath"/* < "$permissionsdir"/folder_permissions.snacl # sets division folders permissions in the Project
  echo "Setting permissions on toplevel project folder."
             /usr/local/bin/snacl -E "$projectpath" < "$permissionsdir"/toplevel_permissions.snacl # sets toplevel permissions for the Project
}

permissionsdir=/HEIMDALL/LIBRARY/studio/makeproj/

if [[ ! -d $permissionsdir ]]; then
  permissionsdir=/home/admin/Documents/makeproj/
  # this home folder is located on the Archiware / p5 server!
fi

cd $HOME

if [[ -z $1 ]]; then
    echo "First variable not set."
    echo "Please input project name."
    read projectname
    projectpath=$(find /HEIMDALL/PROJECTS -type d -iname "*$projectname*")
    echo "project path found at $projectpath"
else

  projectname="$1"
  projectpath=$(find /HEIMDALL/PROJECTS -type d -iname "*$projectname*")
  echo "project path found at $projectpath"

fi

if [[ -d $projectpath ]]; then

  runsnacl

fi

