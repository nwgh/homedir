#!/bin/sh
NOVACOM=/opt/Palm/novacom/novacom 

if [ ! -e "$NOVACOM" ]
then
	echo "Please install the latest version of palmtools before proceeding."
	exit
fi

if [ "$($NOVACOM -l)" = "" ]
then
    echo "Can't find a device."
    exit
fi

novacom put mem://0x8000000 < build-bootstage2-windsor-manufacturing/bootstage2.bin

echo "go 0x8000000" | novacom run file://

echo -n "Waiting for windsor manufacturing bootie to boot"
while [ "$($NOVACOM -l)" = "" ]
do
	echo -n "."
	sleep 1
done
echo ""

echo "Done."
