source $HOME/.zsh.d/prompt_functions.zsh

precmd_functions+="make_topline"
export precmd_functions
export PROMPT="\$(make_pwdprompt)%(!.#.>) "
export RPROMPT="\$(make_sshprompt)"
