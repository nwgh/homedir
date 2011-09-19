#!/bin/sh

if [[ -f /Users/hurley/.disable_mc_autoupdate ]] ; then
    exit 0
fi

CTRLP_CACHE="$HOME/.ctrlp_cache"
if [[ -x /opt/local/bin/ack ]] ; then
    ACK=/opt/local/bin/ack
elif [[ -x /usr/local/bin/ack ]] ; then
    ACK=/usr/local/bin/ack
elif [[ -x /usr/bin/ack ]] ; then
    ACK=/usr/bin/ack
else
    exit 0
fi

if [[ -n "$1" && "$1" != "$HOME" && "$1" != "$HOME/" ]] ; then
    OUTFILE=$(echo "$1.txt" | sed -e 's/\//%/g')
    $ACK --noenv --skipped --text -f "$1" > "$CTRLP_CACHE/$OUTFILE.tmp"
else
    OUTFILE=$(echo "$HOME.txt" | sed -e 's/\//%/g')
    $ACK --noenv --skipped --text -f src/mozilla-central/ | grep -v '/obj-f' > "$CTRLP_CACHE/$OUTFILE.tmp"
fi

mv "$CTRLP_CACHE/$OUTFILE.tmp" "$CTRLP_CACHE/$OUTFILE"

exit 0
