if [ -d /usr/local/share/python ] ; then
    export PATH=/usr/local/share/python:$PATH
fi
if [ -d /usr/local/share/npm/bin ] ; then
    export PATH=/usr/local/share/npm/bin:$PATH
fi
if [ -d /usr/local/share/man ] ; then
    export MANPATH=/usr/local/share/man:$MANPATH
fi
