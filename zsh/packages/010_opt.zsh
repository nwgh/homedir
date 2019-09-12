if [ -d /opt/local/bin ] ; then
   export PATH=/opt/local/bin:/opt/local/sbin:$PATH
fi

if [ -d /opt/local/share/man ] ; then
    export MANPATH=/opt/local/share/man:$MANPATH
fi
if [ -d /opt/local/share/info ] ; then
    export INFOPATH=/opt/local/share/info:$INFOPATH
fi
