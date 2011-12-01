#!/bin/bash
IOR=$(/usr/sbin/ioreg -l)
MAX=$(echo "$IOR" | /usr/bin/grep MaxCapacity | /usr/bin/cut -d= -f2 | /usr/bin/sed -e 's/ //g')
CUR=$(echo "$IOR" | /usr/bin/grep CurrentCapacity | /usr/bin/cut -d= -f2 | /usr/bin/sed -e 's/ //g')
EXT=$(echo "$IOR" | /usr/bin/grep ExternalConnected | /usr/bin/cut -d= -f2 | /usr/bin/sed -e 's/ //g')
MIN=$(echo "$IOR" | /usr/bin/grep TimeRemaining | /usr/bin/cut -d= -f2 | /usr/bin/sed -e 's/ //g')
echo $CUR $MAX $EXT $MIN
