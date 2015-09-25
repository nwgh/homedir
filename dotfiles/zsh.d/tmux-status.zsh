source $HOME/.zsh.d/prompt_functions.zsh

cd "$(tmux display-message -p -F "#{pane_current_path}" -t0)"
VIRTUAL_ENV="$(tmux display-message -p -F "#T" -t0)"
export VIRTUAL_ENV
topline="$(TMUX="" make_topline)"
sshprompt="$(TMUX="" make_sshprompt)"
statusline="$topline"
if [ -n "$statusline" ] ; then
    if [ -n "$sshprompt" ] ; then
        statusline="$statusline $sshprompt"
    fi
else
    if [ -n "$sshprompt" ] ; then
        statusline="$sshprompt"
    fi
fi
echo "$statusline"
