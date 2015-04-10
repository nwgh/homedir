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

_add_to_nspr_log_modules() {
    local module;
    module="$1"
    if [[ -z "$module" ]] ; then
        return
    fi

    if [[ -z "$NSPR_LOG_MODULES" ]] ; then
        NSPR_LOG_MODULES=timestamp
        export NSPR_LOG_FILE=/tmp/nspr.log
    fi

    NSPR_LOG_MODULES="$NSPR_LOG_MODULES","$module"
    export NSPR_LOG_MODULES
}

_cleanup_nspr_logging() {
    unset NSPR_LOG_MODULES
    unset NSPR_LOG_FILE
}

seerlog() {
    _add_to_nspr_log_modules "NetworkPredictor:5"
    "$@"
    _cleanup_nspr_logging
}

httplog() {
    _add_to_nspr_log_modules "nsHttp:5"
    "$@"
    _cleanup_nspr_logging
}

socketlog() {
    _add_to_nspr_log_modules "nsSocketTransport:5"
    "$@"
    _cleanup_nspr_logging
}

dnslog() {
    _add_to_nspr_log_modules "nsHostResolver:5"
    "$@"
    _cleanup_nspr_logging
}

keylog() {
    export SSLKEYLOGFILE=/tmp/nsskeys.log
    "$@"
    unset SSLKEYLOGFILE
}

alias debugnoclean='touch ~/.mozprofiles/debug/nwgh_do_not_clean'
