alias l='/bin/ls --color=auto'
alias ls='/bin/ls --color=auto'
alias la='/bin/ls -A --color=auto'
alias ll='/bin/ls -Al --color=auto'
open() {
    xdg-open "$@" 2>>/tmp/open-${USER}
}
export MINIDUMP_STACKWALK="${HOME}/Dropbox/Documents/moz/minidump_stackwalk_linux_x86"
export NWH_ZSH_CONFIG="linux"
export MOZCONFIG="$MOZCONFIG_ROOT/linux_debug_noopt"

if [ -d "$HOME/.linuxbrew" ] ; then
	# Linuxbrew needs to be at the front to override anything that may also
	# have been installed by system packages
	export PATH="$HOME/.linuxbrew/bin:$PATH"
fi

# vim: set noexpandtab:
