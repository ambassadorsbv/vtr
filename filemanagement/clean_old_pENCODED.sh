#!/usr/bin/env bash

onemonth=$(date -v -1m +%Y%m%d)

find /ODIN/LIBRARY/pENCODED/ \
-type f -not -iname "*.log" \
-and -not -iname "*.sh" \
-and -not -newermt "$onemonth" \
-and \( -iname "*.mov" -or -iname "*.mp4" -or -iname "*.mxf" \) \
-exec rm -fv {} \;
