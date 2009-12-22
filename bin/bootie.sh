#!/bin/sh

if [ ! -d .git ]; then
	echo "Must be run from top-level bootie directory!"
	exit 1
fi

if ! grep 'bootie' doxyfile > /dev/null 2>&1 ; then
	echo "This doesn't appear to be a bootie directory!"
	exit 1
fi

CPUBOOT_CMD="cpuboot -d usb -f ./build-boot-windsor-manufacturing/boot.bin -o"

echo "make"
make

echo
echo "$CPUBOOT_CMD"
$CPUBOOT_CMD

echo
echo "novaterm -w"
novaterm -w
