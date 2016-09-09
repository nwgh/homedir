source $HOME/.zsh.d/prompt_functions.zsh

export PROMPT="\$(make_pwdprompt)%(!.#.>) "
export RPROMPT="\$(make_sshprompt)"
