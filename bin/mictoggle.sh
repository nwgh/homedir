#!/usr/bin/env zsh

VOL_CACHE="${HOME}/.local/mic_volume"

if [[ "$(uname)" != "Darwin" ]] ; then
	print "Only works on macOS"
	exit 1
fi

curr_vol="$(osascript -e "input volume of (get volume settings)")"
if [[ "${curr_vol}" == "0" ]] ; then
	if [[ -f "${VOL_CACHE}" ]] ; then
		new_vol="$(cat ${VOL_CACHE})"
	else
		new_vol="75"
	fi
        msg="Unmuted"
else
	echo "${curr_vol}" > "${VOL_CACHE}"
	new_vol="0"
        msg="Muted"
fi
osascript -e "set volume input volume ${new_vol}"
osascript -e "display notification \"Microphone ${msg}\""
