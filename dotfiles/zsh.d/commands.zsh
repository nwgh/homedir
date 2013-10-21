# Do the smart thing when grepping, but leave plain ol' grep available if
# necessary
if type ack > /dev/null 2>&1 ; then
    alias ggrep=ack
else
    ggrep() {
        if git rev-parse --show-toplevel > /dev/null 2>&1 ; then
            git grep -n --no-index -I "$@"
        else
            grep --color=yes -n -r -I "$@" | less -FRSXi
        fi
    }
fi
alias igrep='ggrep -i'

_do_find() {
    spath="$2"

    if [[ -z "$spath" ]] ; then
        spath="."
    fi

    find "$spath" -"$3"name "*$1*" | $PAGER
}

ffind() {
    _do_find "$1" "$2"
}

ifind() {
    _do_find "$1" "$2" i
}

# Some global aliases
alias mq='hg -R $(hg root)/.hg/patches'

if type dgit > /dev/null 2>&1 ; then
    # Use git with defaults, but make completion still work
    alias git=dgit
    compdef dgit=git
fi

httplog() {
    export NSPR_LOG_MODULES=timestamp,nsHttp:5,nsSocketTransport:5,nsHostResolver:5
    export NSPR_LOG_FILE=~/nspr.log
    "$@"
}
