if [ -d /usr/local/share/npm/bin ] ; then
    export PATH=/usr/local/share/npm/bin:$PATH
fi
if [ -d /usr/local/share/man ] ; then
    export MANPATH=/usr/local/share/man:$MANPATH
fi
if [ -d /home/linuxbrew/.linuxbrew/bin ] ; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [ -d /opt/homebrew/bin ] ; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
