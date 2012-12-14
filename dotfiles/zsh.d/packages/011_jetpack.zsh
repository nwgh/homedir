if [ -d /opt/jetpack ] ; then
    jetpack() {
        OLDPWD=$(pwd)
        cd /opt/jetpack/latest
        source bin/activate
        cd "$OLDPWD"
    }

    cfx() {
        jetpack > /dev/null 2>&1
        /opt/jetpack/latest/bin/cfx "$*"
        deactivate > /dev/null 2>&1
    }
fi
