PYTHON_VERSION=$(cat "$HOME/.python-version" 2>/dev/null)
PYENV_VWRAPPER="$HOME/.pyenv/versions/$PYTHON_VERSION/bin/virtualenvwrapper.sh"
if [ -n "$PYTHON_VERSION" -a -f "$PYENV_WRAPPER" ] ; then
    source "$PYENV_WRAPPER"
elif [ -f /usr/local/bin/virtualenvwrapper.sh ] ; then
    source /usr/local/bin/virtualenvwrapper.sh
fi
