if [[ -f "${HOME}/.pyenv/bin/pyenv" ]] ; then
    export PYENV_ROOT="${HOME}/.pyenv"
    export PATH="${PYENV_ROOT}/bin:${PATH}"
    eval "$(pyenv init --path)"
elif [[ -f "/usr/local/bin/pyenv" ]] ; then
    eval "$(pyenv init --path)"
fi
if which pyenv > /dev/null 2>&1 ; then
    eval "$(pyenv init -)"
fi
