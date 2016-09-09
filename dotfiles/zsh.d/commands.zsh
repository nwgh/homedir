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
alias mq='hg -R $(hg root)/.hg/patches'

if type dgit > /dev/null 2>&1 ; then
    # Use git with defaults, but make completion still work
    alias git=dgit
    compdef dgit=git
fi

logfile() {
    export NSPR_LOG_FILE="$1"
    export MOZ_LOG_FILE="$1"
    shift
    "$@"
    unset MOZ_LOG_FILE
    unset NSPR_LOG_FILE
}

_add_to_nspr_log_modules() {
    local module;
    module="$1"
    if [[ -z "$module" ]] ; then
        return
    fi

    if [[ -z "$MOZ_LOG" ]] ; then
        MOZ_LOG=timestamp
        NSPR_LOG_MODULES=timestamp
    fi
    if [[ -z "$MOZ_LOG_FILE" ]] ; then
        export MOZ_LOG_FILE=/tmp/nspr.log
        export NSPR_LOG_FILE=/tmp/nspr.log
    fi

    MOZ_LOG="$MOZ_LOG","$module"
    NSPR_LOG_MODULES="$NSPR_LOG_MODULES","$module"
    export MOZ_LOG NSPR_LOG_MODULES
}

_cleanup_nspr_logging() {
    unset NSPR_LOG_MODULES
    unset NSPR_LOG_FILE
    unset MOZ_LOG_FILE
    unset MOZ_LOG
}

seerlog() {
    _add_to_nspr_log_modules "NetworkPredictor:5"
    "$@"
    _cleanup_nspr_logging
}

httplog() {
    _add_to_nspr_log_modules "nsHttp:5"
    keylog "$@"
    _cleanup_nspr_logging
}

socketlog() {
    _add_to_nspr_log_modules "nsSocketTransport:5"
    "$@"
    _cleanup_nspr_logging
}

dnslog() {
    _add_to_nspr_log_modules "nsHostResolver:5"
    "$@"
    _cleanup_nspr_logging
}

cookielog() {
    _add_to_nspr_log_modules "cookie:4"
    "$@"
    _cleanup_nspr_logging
}

cachelog() {
    _add_to_nspr_log_modules "cache2:5"
    "$@"
    _cleanup_nspr_logging
}

mozlog() {
    logmodule="$1"
    shift
    _add_to_nspr_log_modules "$logmodule:5"
    "$@"
    _cleanup_nspr_logging
}

keylog() {
    export SSLKEYLOGFILE=/tmp/nsskeys.log
    "$@"
    unset SSLKEYLOGFILE
}

keylogtofile() {
    export SSLKEYLOGFILE="$1"
    shift
    "$@"
    unset SSLKEYLOGFILE
}

alias debugnoclean='touch ~/.mozprofiles/debug/nwgh_do_not_clean'

dd() {
    echo "Are you sure you want to use raw dd? Try"
    echo "    pv <inputfile> | /bin/dd of=<outputfile>"
    echo "(or just call /bin/dd directly)"
}

vcsinfo() {
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

    vcs_data=""

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
                        aheadcount="$(echo "$part1" | cut -d' ' -f2)"
                        behindcount="$(echo "$part2" | cut -d' ' -f3)"
                        ab="${aheadcount}⥮${behindcount} "
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
            vcs_data="$prefix $ab$add$modify$rename$conflict"
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
                OIFS="$IFS"
                IFS=$'\n'
                for line in $(hg fxheads -T "{node|short}:{fxheads}\n")
                do
                    headnode="$(echo "$line" | cut -d: -f1)"
                    head="$(echo "$line" | cut -d: -f2)"
                    if [[ "$node" == "$headnode" ]] ; then
                        branch="$head"
                    fi
                done
                IFS="$OIFS"
            else
                branch="$hgbranch"
            fi
            vcs_data="☿ $branch"
            action="$(echo $vcs_info_msg_0_ | cut -d' ' -f2)"
            if [ -n "$action" ] ; then
                vcs_data="$vcs_data $action"
            fi
            commitcount=0
            if [[ -n "$bookmark" ]] ; then
                commitcount="$(hg log -r 'only(.) and not(public())' --template "{node}\n" | wc -l | sed -e "s/ //g")"
            fi
            if [[ ( $commitcount -gt 0 ) ]] ; then
                outcount="$(hg out -r . -q | wc -l | sed -e "s/ //g")"
                vcs_data="$vcs_data ↑$commitcount/$outcount"
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
                vcs_data="$vcs_data A$addcount"
            fi
            if [[ ( $removedcount -gt 0 ) ]] ; then
                vcs_data="$vcs_data R$removedcount"
            fi
            if [[ ( $modifycount -gt 0 ) ]] ; then
                vcs_data="$vcs_data M$modifycount"
            fi
            if [[ ( $missingcount -gt 0 ) ]] ; then
                vcs_data="$vcs_data !$missingcount"
            fi
            if [[ ( $untrackedcount -gt 0 ) ]] ; then
                vcs_data="$vcs_data ?$untrackedcount"
            fi
        fi
    fi

    echo -e "$vcs_data"
}
