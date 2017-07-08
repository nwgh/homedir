if [[ -d "${HOME}/.local/npm" ]] ; then
    export PATH="${PATH}:${HOME}/.local/npm/bin"
    npm config set prefix "${HOME}/.local/npm"
fi
