PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
if [ -d $HOME/bin ] ; then
    PATH=$PATH:$HOME/bin
fi
export PATH

export PYTHONSTARTUP=~/.pythonrc
export HISTFILE=~/.zsh_history
export HISTSIZE=5000
export SAVEHIST=5000
export LANG=en_US.UTF-8
export PAGER=less
export RSYNC_RSH=ssh
export TZ=PST8PDT
export LESS=-FRXi
export GIT_DIFF_OPTS=--unified=8
export HOMEBREW_NO_EMOJI=1
export HOMEBREW_NO_ANALYTICS=1
if [ "$TERM" = "xterm" ] ; then
	export TERM=xterm-256color
fi

chpwd_functions=()
precmd_functions=()
export chpwd_functions precmd_functions
# vim: set noexpandtab:
