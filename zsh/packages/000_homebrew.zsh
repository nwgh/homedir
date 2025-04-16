if [ -d /usr/local/share/npm/bin ] ; then
    export PATH=/usr/local/share/npm/bin:$PATH
fi
if [ -d /usr/local/share/man ] ; then
    export MANPATH=/usr/local/share/man:$MANPATH
fi
if [ -x /opt/homebrew/bin/brew ] ; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ] ; then
    eval "$(/usr/local/bin/brew shellenv)"
elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ] ; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
