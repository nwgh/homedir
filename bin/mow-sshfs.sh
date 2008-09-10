#!/bin/bash

DEVBOX=moreh.mow.arbor.net
VOLNAME=moreh
ME=$USER
MDIR=/Volumes/${VOLNAME}

df | grep "sshfs#root@$DEVBOX" > /dev/null && \
	echo "$DEVBOX already mounted!" && exit 1

echo "making $MDIR"
mkdir -p $MDIR

# make sure that sftp is enabled
ssh root@${DEVBOX} "grep sftp /etc/ssh/sshd_config >/dev/null || echo Subsystem	sftp	/usr/libexec/sftp-server >> /etc/ssh/sshd_config; kill -HUP \`ps auxwww | grep /usr/sbin/sshd | grep -v grep | awk '{print \$2}'\`"

echo "mounting root@${DEVBOX} at $MDIR"
sshfs root@${DEVBOX}:/ $MDIR -ouid=`id -u`,workaround=rename,reconnect,nolocalcaches,cache=no,volname=${VOLNAME},fsname=${VOLNAME}
