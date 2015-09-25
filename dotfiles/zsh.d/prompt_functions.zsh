# vcs info config
autoload vcs_info
zstyle ':vcs_info:*' enable git hg
zstyle ':vcs_info:*:prompt:*' get-revision "true"
zstyle ':vcs_info:hg:prompt:*' use-simple "true"
zstyle ':vcs_info:hg:prompt:*' get-bookmarks "true"
#zstyle ':vcs_info:*:prompt:*' check-for-changes "true"
#zstyle ':vcs_info:*:prompt:*' check-for-staged-changes "true"
#zstyle ':vcs_info:*:prompt:*' stagedstr ""
#zstyle ':vcs_info:*:prompt:*' unstagedstr ""
zstyle ':vcs_info:hg:prompt:*' hgrevformat "%h"
zstyle ':vcs_info:git:prompt:*' formats "λ $fg[blue]%b$reset_color"
zstyle ':vcs_info:hg:prompt:*' formats "☿ "
zstyle ':vcs_info:git:prompt:*' actionformats "λ $fg[blue]%b$reset_color $fg[red]%a$reset_color"
zstyle ':vcs_info:hg:prompt:*' actionformats "☿ %a"

function make_sshprompt {
    if [ -n "$TMUX" ] ; then
        return
    fi
    ssh_prompt=""
    if [ -n "$SSH_CONNECTION" ] ; then
        ssh_prompt="$PR_RED%m$PR_RESET"
    fi
    echo -e "$ssh_prompt"
}

function make_vcsprompt {
    vcs_prompt=""

    vcs_info prompt

    if [[ -n "$vcs_info_msg_0_" ]] ; then
        vtype="$(echo "$vcs_info_msg_0_" | cut -d' ' -f1)"
        if [[ $vtype = "λ" ]] ; then
            # We got git
            prefix="$vcs_info_msg_0_"
            branchinfo=""
            addcount=0
            deletecount=0
            modifycount=0
            renamecount=0
            conflictcount=0
            untrackedcount=0
            unstagedcount=0
            missingcount=0
            ab=""
            OIFS="$IFS"
            IFS=$'\n'
            for line in $(git status -b --porcelain) ; do
                if [ -n "$branchinfo" ] ; then
                    # We've reached the lines that show us file info
                    staged="$(echo "$line" | cut -c1)"
                    unstaged="$(echo "$line" | cut -c2)"
                    case $staged in
                        "A" )
                            addcount=$((addcount + 1))
                            ;;
                        "D" )
                            deletecount=$((deletecount + 1))
                            ;;
                        "M" )
                            modifycount=$((modifycount + 1))
                            ;;
                        "R" )
                            renamecount=$((renamecount + 1))
                            ;;
                        "U" )
                            conflictcount=$((conflictcount + 1))
                            ;;
                        "?" )
                            untrackedcount=$((untrackedcount + 1))
                            ;;
                    esac
                    case $unstaged in
                        "D" )
                            missingcount=$((dirtycount + 1))
                            ;;
                        "M" )
                            unstagedcount=$((unstagedcount + 1))
                            ;;
                    esac
                else
                    branchinfo="$line"
                    aheadbehind="$(echo "$branchinfo" | cut -d\[ -f2)"
                    aheadbehind="$(echo "$aheadbehind" | cut -d\] -f1)"
                    part1="$(echo "$aheadbehind" | cut -d, -f1)"
                    part2="$(echo "$aheadbehind" | cut -d, -f2)"
                    if [ "$aheadbehind" = "$branchinfo" ] ; then # in sync
                        ab=""
                    elif [ "$part1" = "$part2" ] ; then # $aheadbehind = "{ahead,behind} n"
                        abtype="$(echo "$part1" | cut -d' ' -f1)"
                        count="$(echo "$part1" | cut -d' ' -f2)"
                        if [ $abtype = "ahead" ] ; then
                            ab="↑"
                        else # $abtype = "behind"
                            ab="↓"
                        fi
                        ab="$ab$count "
                    else # $aheadbehind = "ahead n, behind m"
                        aheadcount = "$(echo "$part1" | cut -d' ' -f2)"
                        behindcount = "$(echo "$part2" | cut -d' ' -f2)"
                        ab="⥮$aheadcount/$behindcount "
                    fi
                fi
            done
            IFS="$OIFS"
            add=""
            if [[ ( $addcount -gt 0 ) || ( $untrackedcount -gt 0 ) ]] ; then
                if [ $addcount -gt 0 ] ; then
                    add="$fg[green]$addcount$reset_color"
                fi
                add="${add}A"
                if [ $untrackedcount -gt 0 ] ; then
                    add="$add$fg[red]$untrackedcount$reset_color"
                fi
                add="$add "
            fi

            modify=""
            if [[ ( $modifycount -gt 0 ) || ( $unstagedcount -gt 0 ) ]] ; then
                if [ $modifycount -gt 0 ] ; then
                    modify="$fg[green]$modifycount$reset_color"
                fi
                modify="${modify}M"
                if [ $unstagedcount -gt 0 ] ; then
                    modify="$modify$fg[red]$unstagedcount$reset_color"
                fi
                modify="$modify "
            fi

            delete=""
            if [[ ( $deletecount -gt 0 ) || ( $missingcount -gt 0 ) ]] ; then
                if [ $deletecount -gt 0 ] ; then
                    delete="$fg[green]$deletecount$reset_color"
                fi
                delete="${delete}D"
                if [ $missingcount -gt 0 ] ; then
                    delete="$delete$fg[red]$missingcount$reset_color"
                fi
                delete="$delete "
            fi

            rename=""
            if [ $renamecount -gt 0 ] ; then
                rename="$fg[green]$renamecount${reset_color}R "
            fi

            conflict=""
            if [ $conflictcount -gt 0 ] ; then
                conflict="$fg[red]$conflictcount${reset_color}C "
            fi
            vcs_prompt="$prefix $ab$add$modify$rename$conflict\b"
        else
            # We got mercurial
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
            vcs_prompt="☿ $fg[blue]$branch$reset_color"
            action="$(echo $vcs_info_msg_0_ | cut -d' ' -f2)"
            if [ -n "$action" ] ; then
                vcs_prompt="$vcs_prompt $fg[red]$action$reset_color"
            fi
        fi
    fi

    echo -e "$vcs_prompt"
}

function make_virtualenvprompt {
    if [ -n "$TMUX" ] ; then
        VIRTUAL_ENV="$(tmux display-message -p -F "#T" -t0)"
    fi
    virtualenv_prompt=""
    if [ -n "$VIRTUAL_ENV" ] ; then
        virtualenv_prompt="$fg[green]$(basename "$VIRTUAL_ENV")$reset_color"
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
            finalbits+="$(echo "$bit" | cut -c1)"
        done
        rval="${(j./.)finalbits}/${pcttilde:t}"
    fi
    echo -e "$rval"
}

function make_topline {
    if [ -n "$TMUX" ] ; then
        printf "\033]2;$VIRTUAL_ENV\033\\"
        return
    fi
    virtualenvprompt="$(make_virtualenvprompt)"
    topline="$(make_vcsprompt)"
    if [ -n "$virtualenvprompt" ] ; then
        if [ -n "$topline" ] ; then
            topline="$topline "
        fi
        topline="$topline$virtualenvprompt"
    fi
    if [ -n "$topline" ] ; then
        echo "$topline"
    fi
}
