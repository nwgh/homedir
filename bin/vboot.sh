#!/bin/sh
CPUBOOT=/opt/nova/bin/cpuboot
NOVACOM=/opt/Palm/novacom/novacom
VPATH=/home/hurley/src/windsor/validation

if [ ! -e "$NOVACOM" ] ; then
	echo "Can't find $NOVACOM. Exiting"
	exit 1
fi
if [ ! -x $CPUBOOT ] ; then
	echo "Can't find $CPUBOOT. Exiting"
	exit 1
fi

$CPUBOOT -d usb -f $VPATH/chainboot.bin -o

sleep 3

$CPUBOOT -d usb -f $VPATH/boot.bin -o

echo -n "Waiting for device to boot..."
while [ "$($NOVACOM -l)" = "" ]
do
	echo -n "."
	sleep 1
done
echo
echo

echo "Loading tp fw into memory..."
novacom put mem://0x100000 < $VPATH/toyo.hex
echo

echo "Starting novaterm (hit enter to see prompt)"
novaterm -w
