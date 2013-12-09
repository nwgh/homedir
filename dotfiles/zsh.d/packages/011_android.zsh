if [ -d /opt/android ] ; then
    if [ -d /opt/android/tools ] ; then
        PATH=/opt/android/tools:$PATH
    fi
    if [ -d /opt/android/build-tools/18.1.1 ] ; then
        PATH=/opt/android/build-tools/18.1.1:$PATH
    fi
    if [ -d /opt/android/platform-tools ] ; then
        PATH=/opt/android/platform-tools:$PATH
    fi
    export ANDROID_SDK=/opt/android
    export PATH
fi
