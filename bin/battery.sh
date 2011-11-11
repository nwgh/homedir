#!/bin/bash
ioreg -l | grep -i capacity | tr '\n' ' | ' | awk '{printf("%.1f%%", $10/$5 * 100)}'
