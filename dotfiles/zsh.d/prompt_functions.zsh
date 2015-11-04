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
zstyle ':vcs_info:git:prompt:*' formats "λ %b"
zstyle ':vcs_info:hg:prompt:*' formats "☿ "
zstyle ':vcs_info:git:prompt:*' actionformats "λ %b %a"
zstyle ':vcs_info:hg:prompt:*' actionformats "☿ %a"

function make_sshprompt {
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
                            missingcount=$((missingcount + 1))
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
                    add="$addcount"
                fi
                add="${add}A"
                if [ $untrackedcount -gt 0 ] ; then
                    add="$add$untrackedcount"
                fi
                add="$add "
            fi

            modify=""
            if [[ ( $modifycount -gt 0 ) || ( $unstagedcount -gt 0 ) ]] ; then
                if [ $modifycount -gt 0 ] ; then
                    modify="$modifycount"
                fi
                modify="${modify}M"
                if [ $unstagedcount -gt 0 ] ; then
                    modify="$modify$unstagedcount"
                fi
                modify="$modify "
            fi

            delete=""
            if [[ ( $deletecount -gt 0 ) || ( $missingcount -gt 0 ) ]] ; then
                if [ $deletecount -gt 0 ] ; then
                    delete="$deletecount"
                fi
                delete="${delete}D"
                if [ $missingcount -gt 0 ] ; then
                    delete="$delete$missingcount"
                fi
                delete="$delete "
            fi

            rename=""
            if [ $renamecount -gt 0 ] ; then
                rename="${renamecount}R "
            fi

            conflict=""
            if [ $conflictcount -gt 0 ] ; then
                conflict="${conflictcount}C "
            fi
            vcs_prompt="$prefix $ab$add$modify$rename$conflict"
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
            vcs_prompt="☿ $branch"
            action="$(echo $vcs_info_msg_0_ | cut -d' ' -f2)"
            if [ -n "$action" ] ; then
                vcs_prompt="$vcs_prompt $action"
            fi
            commitcount=0
            if [[ -n "$bookmark" ]] ; then
                commitcount="$(hg log -r 'only(.) and not(public())' --template "{node}\n" | wc -l | sed -e "s/ //g")"
            fi
            if [[ ( $commitcount -gt 0 ) ]] ; then
                outcount="$(hg out -r . -q | wc -l | sed -e "s/ //g")"
                vcs_prompt="$vcs_prompt ↑$commitcount/$outcount"
            fi
            modifycount=0
            addcount=0
            removedcount=0
            missingcount=0
            untrackedcount=0
            OIFS="$IFS"
            IFS=$'\n'
            for line in $(hg status) ; do
               hgstatus="$(echo "$line" | cut -c1)"
               case $hgstatus in
                   "A" )
                       addcount=$((addcount + 1))
                       ;;
                   "R" )
                       removedcount=$((removedcount + 1))
                       ;;
                   "M" )
                       modifycount=$((modifycount + 1))
                       ;;
                   "!" )
                       missingcount=$((missingcount + 1))
                       ;;
                   "?" )
                       untrackedcount=$((untrackedcount + 1))
                       ;;
               esac
            done
            IFS="$OIFS"
            if [[ ( $addcount -gt 0 ) ]] ; then
                vcs_prompt="$vcs_prompt A$addcount"
            fi
            if [[ ( $removedcount -gt 0 ) ]] ; then
                vcs_prompt="$vcs_prompt R$removedcount"
            fi
            if [[ ( $modifycount -gt 0 ) ]] ; then
                vcs_prompt="$vcs_prompt M$modifycount"
            fi
            if [[ ( $missingcount -gt 0 ) ]] ; then
                vcs_prompt="$vcs_prompt !$missingcount"
            fi
            if [[ ( $untrackedcount -gt 0 ) ]] ; then
                vcs_prompt="$vcs_prompt ?$untrackedcount"
            fi
        fi
    fi

    echo -e "$vcs_prompt"
}

function make_virtualenvprompt {
    virtualenv_prompt=""
    if [ -n "$VIRTUAL_ENV" ] ; then
        virtualenv_prompt="$(basename "$VIRTUAL_ENV")"
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
    echo -e "$rval"
}

function make_topline {
    cd "$1"
    virtualenvprompt="$(make_virtualenvprompt)"
    topline="$(make_vcsprompt)"
    if [ -n "$virtualenvprompt" ] ; then
        topline="$topline$virtualenvprompt"
    fi
    if [ -z "$topline" ] ; then
        topline="Shell"
    fi
    echo -e "$topline"
}

source $HOME/.zsh.d/async.zsh
async_init

function async_term_title_callback {
    echo -ne "\033]0;$3\007"
}

function async_term_title {
    ((!${async_term_title_setup:-0})) && {
        async_start_worker "async_term_title_worker" -u -n
        async_register_callback "async_term_title_worker" async_term_title_callback
        async_term_title_setup=0
    }

    async_job "async_term_title_worker" make_topline "$PWD"
}
