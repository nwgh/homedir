#!/bin/bash

MACHINE=todesschaf.org
VOLNAME=uriel
ME=$USER
MDIR=/Volumes/${VOLNAME}

df | grep "sshfs#$ME@$MACHINE" > /dev/null && echo "$MACHINE already mounted!" && exit 1

mkdir -p $MDIR

sshfs ${ME}@${MACHINE}:/ ${MDIR} -ouid=`id -u`,workaround=rename,reconnect,ping_diskarb,volname=${VOLNAME},fsname=${VOLNAME}
