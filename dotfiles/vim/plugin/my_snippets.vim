" Vim 7 and higher
if v:version < 700
    finish
endif

let g:template['c']['for'] = "for (".g:rs."...".g:re."; ".
            \g:rs."...".g:re."; ".g:rs."...".g:re.") {\<cr>".
            \g:rs."...".g:re."\<cr>}\<cr>"
let g:template['c']['switch'] = "switch (".g:rs."...".g:re.") {\<cr>case ".
            \g:rs."...".g:re.":\<cr>break;\<cr>case ".
            \g:rs."...".g:re.":\<cr>break;\<cr>default:\<cr>break;\<cr>}"
let g:template['c']['if'] = "if (".g:rs."...".g:re.") {\<cr>".
            \g:rs."...".g:re."\<cr>}"
let g:template['c']['while'] = "while (".g:rs."...".g:re.") {\<cr>".
             \g:rs."...".g:re."\<cr>}"
let g:template['c']['ife'] = "if (".g:rs."...".g:re.") {\<cr>".
             \g:rs."...".g:re."\<cr>} else {\<cr>".g:rs."...".g:re."\<cr>}"
let g:template['c']['do'] = "do {\<cr>".g:rs."...".g:re."\<cr>} while (".
             \g:rs."...".g:re.")"
let g:template['c']['getopt'] = "while ((ch = getopt(argc, argv, ".
             \g:rs."...".g:re.")) != -1)\<cr>switch (ch) {\<cr>case ".
             \g:rs."...".g:re.":\<cr>break;\<cr>case ".
             \g:rs."...".g:re.":\<cr>break;\<cr>default:\<cr>break;\<cr>}\<cr>argc -= optind;\<cr>argv += optind;\<cr>"
