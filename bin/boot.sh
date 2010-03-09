#!/bin/sh
NOVACOM=/opt/Palm/novacom/novacom 

if [ ! -e "$NOVACOM" ]
then
	echo "Please install the latest version of palmtools before proceeding."
	exit
fi

cpuboot -d usb -f build-boot-windsor/boot.bin -o

echo -n "Waiting for windsor bootie to boot"
while [ "$($NOVACOM -l)" = "" ]
do
	echo -n "."
	sleep 1
done
echo ""

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
