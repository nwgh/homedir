#!/bin/bash
/usr/sbin/ioreg -l | /usr/bin/grep -i capacity | /usr/bin/tr '\n' ' | ' | /usr/bin/awk '{printf("%.1f%%", $10/$5 * 100)}'
