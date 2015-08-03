# Initialize completion subsystem
fpath=("/usr/local/share/zsh/site-functions" $fpath)
autoload -U compinit
compinit

# Easy-to-use colors for prompts
autoload colors
colors
PR_RED="%{$fg[red]%}"
PR_BLUE="%{$fg[blue]%}"
PR_GREEN="%{$fg[green]%}"
PR_YELLOW="%{$fg[yellow]%}"
PR_RESET="%{$reset_color%}"

#allow tab completion in the middle of a word
setopt complete_in_word

# Don't remove slashes from tab-completed things
setopt no_auto_remove_slash

# Built-in echo is BSD compatible
setopt bsd_echo

# If the name of a dir is typed as a command, CD to that dir
setopt auto_cd

# Don't try to correct spelling of commands/args
setopt no_correct
setopt no_correct_all

# No duplicates anywhere in history
setopt hist_ignore_all_dups
setopt hist_save_no_dups

# All history from all shells everywhere
setopt inc_append_history
setopt extended_history
setopt share_history
setopt hist_fcntl_lock

# Do a pushd every time I cd, don't tell me about it, and don't push dupes
setopt auto_pushd
setopt pushd_silent
setopt pushd_to_home
setopt pushd_ignore_dups

# Case insensitive completion
setopt no_case_glob

# Prompt and such
setopt prompt_subst

# Don't use global RC files, I want full control
setopt no_global_rcs

# Safety first!
setopt rm_star_wait

# Use emacs-style keybindings (muscle memory sucks)
bindkey -e
