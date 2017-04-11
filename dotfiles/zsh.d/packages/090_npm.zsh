if [[ -d "${HOME}/.local/npm" ]] ; then
    npm config set prefix "${HOME}/.local/npm"
    export PATH="${PATH}:${HOME}/.local/npm/bin"
fi
