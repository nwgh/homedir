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
dd() {
    echo "Are you sure you want to use raw dd? Try"
    echo "    pv <inputfile> | /bin/dd of=<outputfile>"
    echo "(or just call /bin/dd directly)"
}

rg() {
    command rg -p "$@" | less -FRXi
}

fixdirs() {
    OLD_CWD="$(pwd)"
    cd
    popd +1
    cd "${OLD_CWD}"
}

vim_empty() {
    vim -u NONE "$@"
}

# Use a plain vi when I do |vi|
if type nvi > /dev/null 2>&1 ; then
    vi() {
        nvi "$@"
    }
    export EDITOR=nvi
elif type vim > /dev/null 2>&1 ; then
    vi() {
        vim_empty "$@"
    }
    export EDITOR=vim_empty
fi

# Use a fancy vim when I do |vim|
if type nvim > /dev/null 2>&1 ; then
    alias vim=nvim
fi

# Alias for doing mdns lookups
mdig() {
    dig -p 5353 @224.0.0.251 "$@"
}
