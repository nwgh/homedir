function make_sshprompt {
    ssh_prompt=""
    if [ -n "$SSH_CONNECTION" ] ; then
        if [ -z "$NWGH_ITERM2_INTEGRATION_ENABLED" ] ; then
            ssh_prompt="$PR_RED%m$PR_RESET"
        fi
    fi
    echo -e "$ssh_prompt"
}

function make_virtualenvprompt {
    virtualenv_prompt=""
    if [ -n "$VIRTUAL_ENV" ] ; then
        virtualenv_prompt="($(basename "$VIRTUAL_ENV"))"
    fi
    echo -e "$virtualenv_prompt"
}

function make_pwdprompt {
    pcttilde="${PWD/#$HOME/~}"
    pwdbits=(${(@s./.)pcttilde})
    rval="$pcttilde"
    if [[ $#pwdbits -gt 1 ]] ; then
        finalbits=()
        head="${pcttilde:h}"
        pwdbits=(${(@s./.)head})
        for bit in $pwdbits ; do
            shortbit="$(echo "$bit" | cut -c1)"
            if [ "$shortbit" = "." ] ; then
                # Add the second char if we're in a dot directory
                shortbit="$shortbit$(echo "$bit" | cut -c2)"
            fi
            finalbits+="$shortbit"
        done
        rval="${(j./.)finalbits}/${pcttilde:t}"

        # Add leading / in case we're outside ~ and not in / or a directory
        # directly under /
        case "$rval[1]" in
            [~/])
                ;;
            *)
                rval="/$rval"
                ;;
        esac
    fi
    virtualenv="$(make_virtualenvprompt)"
    echo -e "$virtualenv$rval"
}
