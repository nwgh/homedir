if [[ -d "${HOME}/.golang" ]] ; then
    export GOPATH="${HOME}/.golang"
fi
if [[ -d "${HOME}/.local/go/bin" ]] ; then
    export PATH="${PATH}:${HOME}/.local/go/bin"
    export GOROOT="${HOME}/.local/go"
fi
