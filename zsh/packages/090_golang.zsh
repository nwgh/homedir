if [[ -d "${HOME}/.golang" ]] ; then
    export GOPATH="${HOME}/.golang"
fi
if [[ -d "${HOME}/.local/go/bin" ]] ; then
    export PATH="${PATH}:${HOME}/.local/go/bin"
    export GOROOT="${HOME}/.local/go"
elif [[ -d "/usr/local/opt/go/libexec/bin" ]] ; then
    export PATH="${PATH}:/usr/local/opt/go/libexec/bin"
    #export GOROOT="/usr/local/opt/go"
fi
