" manpageview.vim : extra commands for manual-handling
" Author: Charles E. Campbell, Jr.
" Date: Mar 25, 2003
" Version: 3
"
" Usage:
"  :Man topic
"  :Man topic booknumber  -or-  :Man booknumber topic
"  :Man topic(booknumber)
"  Put cursor on topic, press "K" while in normal mode
"  :Man      -- will restore position prior to use of :Man
"
"  If your man requires options, please specify them with
"  g:manpageview_options in your <.vimrc>:
"
"   examples: let g:manpageview_options= "-P 'cat -'"
"             let g:manpageview_options= "-c"
"             let g:manpageview_options= "-Tascii"
"
" History:
"  3 : * ignores (...) if it contains commas or double quotes.
"        elides any commas, colons, and semi-colons at end
"      * g:manpageview_options supported
"  2 : saves current session prior to invoking man pages
"      :Man    will restore session.  Requires +mksession
"      for this new command to work.
"  1 : the epoch

" prevent double-loading
if &cp || exists("s:loaded_manpageview")
 finish
endif
let s:loaded_manpageview= 1

" Public Interface:
if !hasmapto('<Plug>ManPageView')
  nmap <unique> K <Plug>ManPageView
endif
nmap <silent> <script> <Plug>ManPageView  :silent call <SID>ManPageView(expand("<cWORD>"))<CR>
com! -nargs=*	Man silent! call <SID>ManPageView(<f-args>)
if has("mksession")
  au VimLeave * call <SID>ManCleanupPosn()
endif

if !exists("g:manpageview_options")
 let g:manpageview_options= ""
endif

" ---------------------------------------------------------------------

" ManPageView: view a manual-page, accepts three formats:
"    :call ManPageView("topic")
"    :call ManPageView(booknumber,"topic")
"    :call ManPageView("topic(booknumber)")
fu! <SID>ManPageView(...)
  set lz

  if a:0 == 0
   if exists("g:ManCurPosn") && has("mksession")
"    call Decho("ManPageView: a:0=".a:0."  g:ManCurPosn exists")
	call s:ManRestorePosn()
   else
    echomsg "***usage*** :Man topic  -or-  :Man topic nmbr"
"    call Decho("ManPageView: a:0=".a:0."  g:ManCurPosn doesn't exist")
   endif
   return

  elseif a:0 == 1
"   call Decho("ManPageView: a:0=".a:0." a:1<".a:1.">")
   if a:1 =~ "("
	" abc(3)
	let a1 = substitute(a:1,'[-+*/;,.:]\+$','','e')
	if a1 =~ '[,"]'
     let manpagetopic= substitute(a1,'[(,"].*$','','e')
     let manpagebook = ""
	else
     let manpagetopic= substitute(a1,'^\(.*\)(\d\+[A-Z]\=),\=','\1','e')
     let manpagebook = substitute(a1,'^.*(\(\d\+\)[A-Z]\=),\=','\1','e')
	endif
   else
    " abc
    let manpagetopic= a:1
    let manpagebook = ""
   endif

  else
   " 3 abc  -or-  abc 3
   if     a:1 =~ '^\d\+'
    let manpagebook = a:1
    let manpagetopic= a:2
   elseif a:2 =~ '^\d\+$'
    let manpagebook = a:2
    let manpagetopic= a:1
   else
	" default: topic book
    let manpagebook = a:2
    let manpagetopic= a:1
   endif
  endif

  " Record current file/position/screen-position
  if !exists("g:ManCurPosn") && has("mksession")
   call s:ManSavePosn()
  endif

  only!
  enew!
  set mod
"  call Decho("manpagebook<".manpagebook."> topic<".manpagetopic.">")
  exe "r!man ".g:manpageview_options." ".manpagebook." ".manpagetopic
  %!col -b
  setlocal ft=man nomod nolist
  set nolz
endfunction

" ---------------------------------------------------------------------

" ManRestorePosn:  uses g:ManCurPosn to restore file/position/screen-position
fu! <SID>ManRestorePosn()
  if exists("g:ManCurPosn")
"  call Decho("ManRestorePosn: g:ManCurPosn<".g:ManCurPosn.">")
   exe 'silent! source '.g:ManCurPosn
   unlet g:ManCurPosn
  endif
endfunction

" ---------------------------------------------------------------------

" ManSavePosn: saves current file, line, column, and screen position
fu! <SID>ManSavePosn()
  let g:ManCurPosn= tempname()
  let keep_ssop   = &ssop
  let &ssop       = 'winpos,buffers,slash,globals,resize,blank,folds,help,options,winsize'
  exe 'silent! mksession! '.g:ManCurPosn
  let &ssop       = keep_ssop
endfunction

" ---------------------------------------------------------------------

" ManCleanupPosn: if one exits a man page
fu! <SID>ManCleanupPosn()
  if exists("g:ManCurPosn") && filereadable(g:ManCurPosn)
   silent! call delete(g:ManCurPosn)
   unlet g:ManCurPosn
  endif
endfunction

" ---------------------------------------------------------------------
