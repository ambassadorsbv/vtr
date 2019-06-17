#!/usr/bin/env bash

IFS=$'\n'
datetime=$(date +%Y%m%d-%H%M)

# # # # # # # # # # # #
# The Hammer Chapter  #
# # # # # # # # # # # #

du -kd1 /AMBASSADORS_SHARED | sort -nr | sed $'s/[[:blank:]]/,/;s/\/.*\///;s/[[:space:]]/-/g;s/\///g;/\,\./d' >> /Volumes/HEIMDALL/LIBRARY/studio/servsizes/all_servers/hammer/shared/shared_$datetime.csv
#
du -kd1 /HAMMER | sed $'s/[[:blank:]]/,/;s/\/.*\///;s/[[:space:]]/-/g;s/\///g;/\,\./d' | sort -nr >> /Volumes/HEIMDALL/LIBRARY/studio/servsizes/all_servers/hammer/hammer/hammer_$datetime.csv

# # # # # # # # # # # #
#    The Projects     #
# # # # # # # # # # # #

find /AMBASSADORS_SHARED/PROJECTS/ -type d -and -iname "*_p1??????" -and -not -ipath "*_p1??????/*_p1??????*" -exec du -kd0 {} \; | sed $'s/[[:blank:]]/,/;s/\/.*\///;s/[[:space:]]/-/g;s/\///g;/\,\./d' | sort -nr  >> /Volumes/HEIMDALL/LIBRARY/studio/servsizes/all_servers/projs/projdirs_$datetime.csv

# # # # # # # # # # # #
#   The Odin Chapter  #
# # # # # # # # # # # #

du -kd1 /ODIN | sed $'s/[[:blank:]]/,/;s/\/.*\///;s/[[:space:]]/-/g;s/\///g;/\,\./d' | sort -nr >> /Volumes/HEIMDALL/LIBRARY/studio/servsizes/all_servers/odin/odin_$datetime.csv
#
find /ODIN/_WORK/ -type d -and -iname "*_p1??????" -and -not -ipath "*_p1??????/*_p1??????*" -exec du -kd0 {} \; | sed 's/[[:blank:]]/,/g;s/\/.*\///' | sed '/\(\..*\)/d;s/\///g;s/[[:space:]]/-/g' | sort -nr >> /Volumes/HEIMDALL/LIBRARY/studio/servsizes/all_servers/work/workdirs_$datetime.csv
#
find /ODIN/LIBRARY/pFINALS/ -type d -and -iname "*_p1??????" -and -not -ipath "*_p1??????/*_p1??????*" -exec du -kd0 {} \; | sed 's/[[:blank:]]/,/g;s/\/.*\///' | sed '/\(\..*\)/d;s/\///g;s/[[:space:]]/-/g' | sort -nr >> /Volumes/HEIMDALL/LIBRARY/studio/servsizes/all_servers/fins/pfins_$datetime.csv

# # # # # # # # # # # #
#     The Rushes      #
# # # # # # # # # # # #

du -kd1 /RUSHES | sed $'s/[[:blank:]]/,/;s/\/.*\///;s/[[:space:]]/-/g;s/\///g;/\,\./d' | sort -nr >> /Volumes/HEIMDALL/LIBRARY/studio/servsizes/all_servers/rushes/rushes_$datetime.csv

# # # # # # # # # # # #
#      Currents       #
# # # # # # # # # # # #

rm -f /Volumes/HEIMDALL/LIBRARY/studio/servsizes/LATEST/*.csv
for latest in /Volumes/HEIMDALL/LIBRARY/studio/servsizes/all_servers/{work,rushes}/*_$datetime.csv; do
  cp "$latest" /Volumes/HEIMDALL/LIBRARY/studio/servsizes/LATEST/
done
