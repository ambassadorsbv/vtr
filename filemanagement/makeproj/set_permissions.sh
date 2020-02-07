#!/usr/bin/env bash
# Set the appropriate rights to a folders

#COMMAND SELECTION BELOW
# User the permissions lists to set the right permissions for folders, using the SN-ACL program. This was copied over from the server itself, and is a proprietary software! If it ever gets lost on this machine, make sure to copy it over from the server again. (Should be in /bin/snacl)


#  sets full permissions to the top level folder Admins and Studio
runtoplevel() { 
  echo "running toplevel permissions on specified path $folderpath "
             /usr/local/bin/snacl -ER "$folderpath" < "$permissionsdir"/toplevel_permissions.snacl
#             /usr/local/bin/snacl -ER "$folderpath/." < "$permissionsdir"/toplevel_permissions.snacl
clear
echo "Last action: set top-level permissions to a folder"
echo ""

}

runvfx () {
  echo "running vfx permissions folders."
             /usr/local/bin/snacl -ER "$vfxallpath"* < "$permissionsdir"/all_permissions.snacl # Gives everyone RW rights to the tree
clear
echo "Last action: Give all divisions modify permissions"
echo ""
}

runproductivity() {
  echo "running productivty permissions on specified path $productivtypath "
             /usr/local/bin/snacl -ER "$productivtypath"* < "$permissionsdir"/productivity_permissions.snacl  # removes write permissions for all but VFX, Edit and Lab
clear
echo "Last action: Remove modify permissions for all but VFX, Edit and Lab (productivity access)"
echo ""
}

runstrippermissions() {
  echo "running productivty permissions on specified path $strippermissions "
             /usr/local/bin/snacl -ER "$strippermissions"* < "$permissionsdir"/toplevel_permissions.snacl  # resets complete structure of the path to readonly for all but Studio and Admins
clear
echo "Last action: Remove Modify Permissions for all folders and files (strip permissions)"
echo ""
}

#=========================
# End of commands section
#=========================


permissionsdir=/HEIMDALL/LIBRARY/studio/scripts/vtr/filemanagement/makeproj/permissions/
echo "==========================================================================================================="
echo "Explanation of options:"
echo "Option 1: read and list permissions for all divisions but Admins and Studio, Applies to this folder only!"
echo "Option 2: Give all divisions Modify permissions to the folder and it's subfolders"
echo "Option 3: Remove Modify permissions for all but VFX, Edit, Sound and Lab (productivity access only)"
echo "Option 4: Remove Modify permissions for all divisions but Admins and Studio (usefull for restored archives)"
echo "Option 5: Quit the script (or just press CTRL-C)"
echo "==========================================================================================================="
echo ""

PS3='Please select your option: '
options=("Set top-level permissions to a folder" "Give all divisions modify permissions" "Remove modify permissions for all but VFX, Edit, Sound and Lab" "Remove Modify Permissions for all folders and files" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Set top-level permissions to a folder")
            echo "We'll $opt " 
            echo "Please input the folder: (i.e /HEIMDALL/PROJECTS/p19/YOURPROJECT/"
		read folderpath

# check if folder exists
DIR=$folderpath
if [ -d "$DIR" ]; then
  ### Take action if $DIR exists ###
  echo "Checking if ${DIR} exists:"
  echo "${DIR} is present continuing ..."
else
  ###  Control will jump here if $DIR does NOT exists ###
  echo "Error: ${DIR} not found. Can not continue."
exit 1
fi

		echo ""
		echo "Setting  top-level permissions to: $folderpath"
		echo "!! MAKE SURE THE PATH IS CORRECT !!"
read -p "Press [Enter] key to continue..."
	runtoplevel
            ;;

        "Give all divisions modify permissions")
            echo "We'll $opt . Please input the folder: (i.e /HEIMDALL/PROJECTS/p19/YOURPROJECT/"
	 read vfxallpath
# check if folder exists
DIR=$vfxallpath
if [ -d "$DIR" ]; then
  ### Take action if $DIR exists ###
  echo "Checking if ${DIR} exists:"
  echo "${DIR} is present continuing..."
else
  ###  Control will jump here if $DIR does NOT exists ###

  echo "Error: ${DIR} not found. Can not continue."
exit 1
fi


         echo ""
         echo "Setting RW permissions for ALL division to: $vfxallpath but only on the subfolders"
         echo "!! MAKE SURE THE PATH IS CORRECT !!"
read -p "Press [Enter] key to continue..."
	runvfx
            ;;

        "Remove modify permissions for all but VFX, Edit, Sound and Lab")
            echo "We'll $opt . Please input the folder: (i.e /HEIMDALL/PROJECTS/p19/YOURPROJECT/subfolder"
            echo "!! Make sure it's a SUB folder in an existing tree of folders !!"

	 read productivitypath
# check if folder exists
DIR=$productivitypath
if [ -d "$DIR" ]; then
  ### Take action if $DIR exists ###
  echo "Checking if ${DIR} exists:"
  echo "${DIR} is present continuing..."
else
  ###  Control will jump here if $DIR does NOT exists ###

  echo "Error: ${DIR} not found. Can not continue."
exit 1
fi

         echo ""
         echo "Removing permissions on: $productivitypath"
         echo ""
read -p "Press [Enter] key to continue..."
        runproductivity
            ;;

        "Remove Modify Permissions for all folders and files")
            echo "We'll $opt on your given path. Only Admins and Studio have full access, all others have read/list "
	    echo "Please input the folder: (i.e /HEIMDALL/PROJECTS/p19/YOURPROJECT/subfolder"
         read strippermissions
# check if folder exists
DIR=$strippermissions
if [ -d "$DIR" ]; then
  ### Take action if $DIR exists ##
  echo "Checking if ${DIR} exists:"#
  echo "${DIR} is present continuing..."
else
  ###  Control will jump here if $DIR does NOT exists ###

  echo "Error: ${DIR} not found. Can not continue."
exit 1
fi

         echo ""
         echo "Removing permissions on: $strippermissions for all but Admins and Studio"
         echo ""
read -p "Press [Enter] key to continue..."
        runstrippermissions
	;;

        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
