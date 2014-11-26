# vcs info config
autoload vcs_info
zstyle ':vcs_info:*' enable git hg
zstyle ':vcs_info:*:prompt:*' get-revision "true"
zstyle ':vcs_info:hg:prompt:*' hgrevformat "%h"
zstyle ':vcs_info:git:prompt:*' formats "%s:%r:%S:%b:%i:"
zstyle ':vcs_info:hg:prompt:*' formats "%s:%r:%S:%b:%i"
zstyle ':vcs_info:git:prompt:*' actionformats "%s:%r:%S:%b:%i::%a"
zstyle ':vcs_info:hg:prompt:*' actionformats "%s:%r:%S:%b:%i:%a"

function make_prompt {
    vcs_info prompt

    if [[ -n "$vcs_info_msg_0_" ]] ; then
        vtype="$(echo "$vcs_info_msg_0_" | cut -d: -f1)"
        repo="$(echo "$vcs_info_msg_0_" | cut -d: -f2)"
        rpath="/$(echo "$vcs_info_msg_0_" | cut -d: -f3 | sed -e 's/^\.//')"
        branch="$(echo "$vcs_info_msg_0_" | cut -d: -f4)"
        sha="$(echo "$vcs_info_msg_0_" | cut -d: -f5)"
        act="$(echo "$vcs_info_msg_0_" | cut -d: -f7)"
        if [[ $vtype = "hg" ]] ; then
            qtop="$(hg qtop 2>/dev/null)"
            if [[ "$qtop" != "no patches applied" ]] ; then
                branch="$qtop"
            else
                hginfo="$(hg log -r . -T "{bookmarks}:{tags}")"
                bookmark="$(echo "$hginfo" | cut -d: -f1 | cut -d' ' -f1)"
                tag="$(echo "$hginfo" | cut -d: -f2 | cut -d' ' -f1)"
                if [[ -n "$bookmark" ]] ; then
                    # Try bookmarks first
                    branch="$bookmark"
                elif [[ -n "$tag" ]] ; then
                    # Next try tags
                    branch="$tag"
                else
                    # Finally get branch name, use sha if that's not the
                    # same as what corresponds to the branch's tip,
                    # otherwise use the branch name
                    branchtip="$(hg log -r "$branch" -T "{node|short}")"
                    if [[ "$sha" != "$branchtip" ]] ; then
                        branch="$sha"
                    fi
                fi
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
