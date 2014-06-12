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
export MINIDUMP_STACKWALK="${HOME}/Todesschaf/Documents/moz/minidump_stackwalk_osx"
export NWH_ZSH_CONFIG="osx"
export MOZCONFIG="$MOZCONFIG_ROOT/mac_debug"
export CFLAGS=-Qunused-arguments
export CPPFLAGS=-Qunused-arguments

# vim: set noexpandtab:
