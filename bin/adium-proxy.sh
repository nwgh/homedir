#!/bin/sh

# Quit adium, so these changes will take effect
/usr/bin/osascript ${HOME}/bin/quit-adium.scpt

# Set all the accounts to use proxy (or not, as the case may be)
accounts="1 2 3 4"

case "$1" in
	"off") _val=0 ;;
	*) _val=1 ;;
esac

for i in ${accounts} ; do
	/usr/libexec/PlistBuddy -c "set '${i}:Proxy Enabled' ${_val}" "${HOME}/Library/Application Support/Adium 2.0/Users/Default/AccountPrefs.plist"
done

# Now go ahead and restart adium, and go online
/usr/bin/osascript ${HOME}/bin/adium-online.scpt

exit 0
