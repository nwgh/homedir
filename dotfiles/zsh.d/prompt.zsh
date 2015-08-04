# vcs info config
autoload vcs_info
zstyle ':vcs_info:*' enable git hg
zstyle ':vcs_info:*:prompt:*' get-revision "true"
zstyle ':vcs_info:hg:prompt:*' hgrevformat "%h"
zstyle ':vcs_info:git:prompt:*' formats "%s:%r:%S:%b:%i:"
zstyle ':vcs_info:hg:prompt:*' formats "%s:%r:%S:%b:%i"
zstyle ':vcs_info:git:prompt:*' actionformats "%s:%r:%S:%b:%i::%a"
zstyle ':vcs_info:hg:prompt:*' actionformats "%s:%r:%S:%b:%i:%a"

function make_rprompt {
    rprompt_string=""
    if [ -n "$SSH_CONNECTION" ] ; then
        rprompt_string="$PR_RED%m$PR_RESET"
    fi

    vcs_info prompt

    if [[ -n "$vcs_info_msg_0_" ]] ; then
        vtype="$(echo "$vcs_info_msg_0_" | cut -d: -f1)"
        repo="$(echo "$vcs_info_msg_0_" | cut -d: -f2)"
        rpath="/$(echo "$vcs_info_msg_0_" | cut -d: -f3 | sed -e 's/^\.//')"
        branch="$(echo "$vcs_info_msg_0_" | cut -d: -f4)"
        sha="$(echo "$vcs_info_msg_0_" | cut -d: -f5)"
        act="$(echo "$vcs_info_msg_0_" | cut -d: -f7)"
        if [[ $vtype = "hg" ]] ; then
            hgp="$(hg prompt "{node|short}:{branch}:{update}:{bookmark}:{tags|quiet}")"
            node="$(echo "$hgp" | cut -d: -f1)"
            hgbranch="$(echo "$hgp" | cut -d: -f2)"
            update="$(echo "$hgp" | cut -d: -f3)"
            bookmark="$(echo "$hgp" | cut -d: -f4)"
            tag="$(echo "$hgp" | cut -d: -f5)"
            if [[ "$tag" == "tip" ]] ; then
                tag=""
            fi
            if [[ -n "$bookmark" ]] ; then
                branch="$bookmark"
            elif [[ -n "$tag" ]] ; then
                branch="$tag"
            elif [[ -n "$update" ]] ; then
                branch="$node"
            else
                branch="$hgbranch"
            fi
        fi
        vcsinfo="$PR_BLUE$branch$PR_RESET"
        if [[ -n "$act" ]] ; then
            vcsinfo="$pathinfo $PR_RED($act)$PR_RESET"
        fi

        rprompt_string="$rprompt_string $vcsinfo"
    fi

    echo -e "$rprompt_string"
}

export PROMPT="%~%(!.#.>) "
export RPROMPT="\$(make_rprompt)"
