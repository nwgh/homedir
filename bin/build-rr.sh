#!/bin/bash

echo " > cd $HOME/src/mozilla/rr"
cd $HOME/src/mozilla/rr
echo " > git clean -fdx"
git clean -fdx
echo " > mkdir obj"
mkdir obj
echo " > cd obj"
cd obj
echo " > cmake -G Ninja"
cmake -G Ninja ..
echo " > ninja-build"
ninja-build
