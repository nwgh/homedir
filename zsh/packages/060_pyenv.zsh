if [[ -f "${HOME}/.pyenv/bin/pyenv" ]] ; then
    export PYENV_ROOT="${HOME}/.pyenv"
    export PATH="${PYENV_ROOT}/bin:${PATH}"
    eval "$(pyenv init - zsh)"
elif which pyenv > /dev/null 2>&1 ; then
    eval "$(pyenv init - zsh)"
fi
