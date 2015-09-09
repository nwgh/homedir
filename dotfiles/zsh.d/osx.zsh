if /bin/ls -G > /dev/null 2>&1; then
	SPECIFIER="-G"
else
	SPECIFIER="-F"
fi
alias l="/bin/ls ${SPECIFIER}"
alias ls="/bin/ls ${SPECIFIER}"
alias la="/bin/ls -A ${SPECIFIER}"
alias ll="/bin/ls -Al ${SPECIFIER}"
alias mvim="mvim --remote-silent"
alias gvim="gvim --remote-silent"
export MINIDUMP_STACKWALK="${HOME}/Dropbox/Documents/moz/minidump_stackwalk_osx"
export NWH_ZSH_CONFIG="osx"
export MOZCONFIG="$MOZCONFIG_ROOT/mac_debug"
export CFLAGS=-Qunused-arguments
export CPPFLAGS=-Qunused-arguments

function irctunnel() {
	case "$1" in
	"start")
		launchctl load -w ~/Library/LaunchAgents/sshtunnel.plist
		;;
	"stop")
		launchctl unload -w ~/Library/LaunchAgents/sshtunnel.plist
		;;
	*)
		echo "Unknown action $1"
		;;
	esac
}

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
