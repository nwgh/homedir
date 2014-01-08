PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
if [ -d $HOME/bin ] ; then
    PATH=$PATH:$HOME/bin
fi
export PATH

export PYTHONSTARTUP=~/.pythonrc
export HISTFILE=~/.zsh_history
export HISTSIZE=500
export SAVEHIST=500
export LANG=en_US.UTF-8
export PAGER=less
export RSYNC_RSH=ssh
export TZ=PST8PDT
export LESS=-FRXi
export GIT_DIFF_OPTS=--unified=8
export PROJECT_HOME="$HOME/src"
export HOMEBREW_NO_EMOJI=1
export BLOG_HOME="$HOME/src/todesschaf.github.com"
export BLOG_POSTS="$BLOG_HOME/_posts"
export MOZCONFIG_ROOT="$HOME/src/mozilla/mozconfigs"
if [ "$TERM" = "xterm" ] ; then
	export TERM=xterm-256color
fi
if [ -f "/todesschaf/bin/vim" ] ; then
	export EDITOR=/todesschaf/bin/vim
elif [ -f "/usr/local/bin/vim" ] ; then
	export EDITOR=/usr/local/bin/vim
fi

# vim: set noexpandtab:
