source "${NWGH_CONFIG_PATH}/zsh/prompt_functions.zsh"

export PROMPT="\$(make_pwdprompt)%(!.#.>) "
export RPROMPT="\$(make_sshprompt)"
