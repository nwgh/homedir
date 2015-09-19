export VIRTUAL_ENV_DISABLE_PROMPT="zomgyesplz"
PYTHON_VERSION=$(cat "$HOME/.python-version" 2>/dev/null)
PYENV_VWRAPPER="$HOME/.pyenv/versions/$PYTHON_VERSION/bin/virtualenvwrapper.sh"
if [ -n "$PYTHON_VERSION" -a -f "$PYENV_WRAPPER" ] ; then
    source "$PYENV_WRAPPER"
elif [ -f /usr/local/bin/virtualenvwrapper.sh ] ; then
    source /usr/local/bin/virtualenvwrapper.sh
fi

if [ -n "$PYENV_SHELL" ] ; then
    pyenv virtualenvwrapper
fi

function nwgh_autovenv {
    if [ -z "$WORKON_HOME" ] ; then
        return
    fi

    local venv=""
    local checkdir="$PWD"
    while [ "$checkdir" != "/" ] ; do
        local venvfile="$checkdir/.venv"
        if [ -f "$venvfile" ] ; then
            venv="$(cat "$venvfile")"
            break
        fi
        checkdir="$(dirname "$checkdir")"
    done

    if [ -n "$venv" ] ; then
        if [ "$venv" != "$VIRTUAL_ENV" ] ; then
            workon "$venv"
        fi
    else
        if [ -n "$VIRTUAL_ENV" ] ; then
            deactivate
        fi
    fi
}

chpwd_functions+="nwgh_autovenv"
export chpwd_functions
