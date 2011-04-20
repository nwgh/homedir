#!/bin/sh
if git rev-parse --show-toplevel 2>/dev/null | grep mozilla-central$ > /dev/null
then
    exec $HOME/bin/moz-update-ctags.sh
fi

exec ctags "$@"
