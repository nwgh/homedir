if [[ -f "${HOME}/.dircolors-solarized" ]] ; then
    eval $(dircolors "${HOME}/.dircolors-solarized")
fi
alias l='/bin/ls --color=auto'
alias ls='/bin/ls --color=auto'
alias la='/bin/ls -A --color=auto'
alias ll='/bin/ls -Al --color=auto'
open() {
    xdg-open "$@" 2>>/tmp/open-${USER}
}
pbcopy() {
    gpaste-client add
}
export NWGH_ZSH_CONFIG="linux"

if [ -d "$HOME/.linuxbrew" ] ; then
	# Linuxbrew needs to be at the front to override anything that may also
	# have been installed by system packages
	export PATH="$HOME/.linuxbrew/bin:$PATH"
elif [ -f "/home/linuxbrew/profile" ] ; then
	source /home/linuxbrew/profile
fi

# vim: set noexpandtab:
