if [ -d "${HOME}/Library/Python/3.8/bin" ] ; then
    export PATH="${PATH}:${HOME}/Library/Python/3.8/bin"
elif [ -d "${HOME}/Library/Python/3.7/bin" ] ; then
    export PATH="${PATH}:${HOME}/Library/Python/3.7/bin"
# TODO - handle linux local path
fi
