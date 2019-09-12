if /bin/ls -G > /dev/null 2>&1; then
	SPECIFIER="-G"
else
	SPECIFIER="-F"
fi
alias l="/bin/ls ${SPECIFIER}"
alias ls="/bin/ls ${SPECIFIER}"
alias la="/bin/ls -A ${SPECIFIER}"
alias ll="/bin/ls -Al ${SPECIFIER}"
export NWGH_ZSH_CONFIG="osx"

# Overwrite from commands.zsh to make this faster on mac
_do_find() {
    spath="$2"

    if [[ -z "$spath" ]] ; then
        spath="."
    fi

    mdfind -onlyin "$spath" -name "$1" | $PAGER
}

alias locate="mdfind -name"

# vim: set noexpandtab:
