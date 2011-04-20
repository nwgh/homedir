#!/bin/sh
ctags -e -R --langmap=C++:+.idl --langmap=C++:+.ipdl \
    --languages=C,C++,HTML,JavaScript,Make,Python --extra=+q \
    --exclude=@${HOME}/Dropbox/moz/mc-ctags-exclude > /dev/null 2>&1
