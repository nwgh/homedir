PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
if [ -d "${NWGH_CONFIG_PATH}/bin" ] ; then
    PATH="${PATH}:${NWGH_CONFIG_PATH}/bin"
fi
export PATH

export PYTHONSTARTUP="${HOME}/.pythonrc"
export HISTFILE="${HOME}/.zsh_history"
export HISTSIZE=5000
export SAVEHIST=5000
export LANG=en_US.UTF-8
export PAGER=less
export RSYNC_RSH=ssh
export TZ=PST8PDT
export LESS=-FRXi
export HOMEBREW_NO_EMOJI=1
export HOMEBREW_NO_ANALYTICS=1
if [ "$TERM" = "xterm" ] ; then
	export TERM=xterm-256color
fi
export RIPGREP_CONFIG_PATH="${HOME}/.ripgreprc"

# Use pinentry for ssh-askpass
export SSH_ASKPASS="${NWGH_CONFIG_PATH}/bin/ssh-askpass-pinentry"
export SSH_ASKPASS_REQUIRE=force

chpwd_functions=()
precmd_functions=()
export chpwd_functions precmd_functions
# vim: set noexpandtab:
