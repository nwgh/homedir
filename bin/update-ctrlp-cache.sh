#!/bin/sh

CTRLP_CACHE="$HOME/.ctrlp_cache"

if [[ -n "$1" && "$1" != "$HOME" && "$1" != "$HOME/" ]] ; then
    OUTFILE=$(echo "$1.txt" | sed -e 's/\//%/g')
    ack --noenv --skipped --text -f "$1" > "$CTRLP_CACHE/$OUTFILE.tmp"
else
    OUTFILE=$(echo "$HOME.txt" | sed -e 's/\//%/g')
    ack --noenv --skipped --text -f src/mozilla-central/ | grep -v '/obj-f' > "$CTRLP_CACHE/$OUTFILE.tmp"
fi

mv "$CTRLP_CACHE/$OUTFILE.tmp" "$CTRLP_CACHE/$OUTFILE"
