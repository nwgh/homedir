#!/bin/sh
git clean -fdx
brew link --force openssl libxml2 zlib
autoreconf -i
automake
autoconf
./configure --enable-debug --disable-threads
make
brew unlink --force openssl libxml2 zlib
