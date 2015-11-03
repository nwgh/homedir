source $HOME/.zsh.d/prompt_functions.zsh

cd "$(tmux display-message -p -F "#{pane_current_path}" -t0)"
VIRTUAL_ENV="$(tmux display-message -p -F "#T" -t0)"
export VIRTUAL_ENV
statusline="$(TMUX="" make_topline)"
echo "$statusline"
