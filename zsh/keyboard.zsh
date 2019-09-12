# Use vim keybindings by default
bindkey -v

# Make some emacs-like keys useful in insert mode
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line

bindkey "^B" backward-char
bindkey "^F" forward-char

bindkey "^P" up-line-or-history
bindkey "^N" down-line-or-history

bindkey "^R" history-incremental-search-backward
bindkey "^S" history-incremental-search-forward

bindkey "^K" kill-line
bindkey "^D" delete-char-or-list

# Make / and ? do incremental searches in command mode
bindkey -a "/" history-incremental-search-backward
bindkey -a "?" history-incremental-search-forward
