if [ -d /opt/android ] ; then
    if [ -d /opt/android/tools ] ; then
        export PATH=/opt/android/tools:$PATH
    fi
    if [ -d /opt/android/platform-tools ] ; then
        PATH=/opt/android/platform-tools:$PATH
    fi
    export ANDROID_SDK=/opt/android
fi
