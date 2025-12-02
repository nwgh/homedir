if ! which pyenv > /dev/null 2>&1 ; then
  function _pyvenv_is_venv()
  {
    local path="${1}"
    local cfg="${path}/pyenv.cfg"
    local act="${path}/bin/activate"
    # A valid environment is constituted by a pyenv.cfg configuration as
    # well as an activate file. We omit sanity checks such as those for
    # readability here. It is impossible to check everything (for
    # instance, the activate script could be corrupted) and we are sort of
    # in a hot path so we do not want to do unnecessary work.
    test -e "${cfg}" -a -e "${act}"
  }

  function _pyvenv_find_venv()
  {
    local path=$(readlink --canonicalize-existing "${1}")

    # As long as we are dealing with a valid (existing) directory, we
    # check it for being a Python venv. If it is we are done.
    while [ $? -eq 0 ]; do
      _pyvenv_is_venv "${path}"
      if [ $? -eq 0 ]; then
        builtin echo "${path}"
        break
      fi

      _pyvenv_is_venv "${path}/.venv"
      if [ $? -eq 0 ]; then
        builtin echo "${path}/.venv"
        break
      fi

      _pyvenv_is_venv "${path}/venv"
      if [ $? -eq 0 ]; then
        builtin echo "${path}/venv"
        break
      fi

      # If we reached the root and have not found a venv then we can stop.
      if [ "${path}" = "/" ]; then
        break
      fi

      path=$(readlink -e "${path}/../")
    done
  }

  function _pyvenv_activate_deactivate()
  {
    local this_pwd="${PWD}"
    # Check whether somewhere in our path there exists a venv.
    local venv=$(_pyvenv_find_venv "${this_pwd}")

    if [ -n "${venv}" ]; then
      # If that is the case we need to differentiate between two cases:
      # the found venv is the same as the one we already activated or it
      # is different. If it is different we deactivate the current one (if
      # any) and activate the found one. If both are equal there is
      # nothing to be done.
      if [ "${venv}" != "${VIRTUAL_ENV:-}" ]; then
        if [ -n "${VIRTUAL_ENV:-}" ]; then
          # A deactivate function is provided by any activated venv. Note
          # that we invoke it with a single (empty) argument because it
          # unconditionally uses ${1} which is otherwise undefined.
          deactivate ""
        fi

        source "${venv}/bin/activate"
      fi
    else
      # If we did not find a valid environment we still might want to
      # deactivate the current one, if any.
      if [ -n "${VIRTUAL_ENV:-}" ]; then
        deactivate ""
      fi
    fi
  }

  autoload -U add-zsh-hook
  add-zsh-hook chpwd _pyvenv_activate_deactivate
fi
