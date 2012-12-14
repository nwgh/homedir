# vcs info config
autoload vcs_info
zstyle ':vcs_info:*' enable git hg
zstyle ':vcs_info:*:prompt:*' formats "%s:%r:%S:%b"
zstyle ':vcs_info:*:prompt:*' actionformats "%s:%r:%S:%b:%a"

function make_prompt {
    vcs_info prompt

    if [[ -n "$vcs_info_msg_0_" ]] ; then
        vtype="$(echo "$vcs_info_msg_0_" | cut -d: -f1)"
        repo="$(echo "$vcs_info_msg_0_" | cut -d: -f2)"
        rpath="/$(echo "$vcs_info_msg_0_" | cut -d: -f3 | sed -e 's/^\.//')"
        branch="$(echo "$vcs_info_msg_0_" | cut -d: -f4)"
        act="$(echo "$vcs_info_msg_0_" | cut -d: -f5)"
        if [[ $vtype = "hg" ]] ; then
            qtop="$(hg qtop 2>/dev/null)"
            if [[ "$qtop" != "no patches applied" ]] ; then
                branch="$qtop"
            fi
        fi
        pathinfo="$PR_GREEN$repo$PR_RESET:$PR_BLUE$branch$PR_RESET"
        if [[ -n "$act" ]] ; then
            pathinfo="$pathinfo $PR_RED($act)$PR_RESET"
        fi
        pathinfo="$pathinfo $rpath"
    else
        pathinfo="%~"
    fi

    echo -e "%m $pathinfo%(!.#.>) "
}

export PROMPT="\$(make_prompt)"
