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
export MOZCONFIG="$MOZCONFIG_ROOT/mac_debug_noopt"
export MOZ_NODE_PATH="/usr/local/bin/node"
export NODE_HTTP2_ROOT="${HOME}/src/node-http2"
export MOZHTTP2_PORT=48872 # "HTTP2" on a phone keypad

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

function startvm() {
	"/Applications/VMware Fusion.app/Contents/Library/vmrun" -T fusion start "${HOME}/Documents/Virtual Machines.localized/Fedora.vmwarevm/Fedora.vmx" nogui
}

function stopvm() {
	"/Applications/VMware Fusion.app/Contents/Library/vmrun" -T fusion stop "${HOME}/Documents/Virtual Machines.localized/Fedora.vmwarevm/Fedora.vmx" soft
}

function killvm() {
	"/Applications/VMware Fusion.app/Contents/Library/vmrun" -T fusion stop "${HOME}/Documents/Virtual Machines.localized/Fedora.vmwarevm/Fedora.vmx" hard
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
