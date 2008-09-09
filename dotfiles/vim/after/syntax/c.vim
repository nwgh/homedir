set noautoindent
set cindent
set cinoptions=+0,:0,(0
set comments=sr:/*,mb:*,ex:*/,://
set formatoptions=tcroq
set nosmartindent
set sts=0

syn keyword cType u_char u_short u_int u_long off_t ssize_t key_t pid_t 
syn keyword cType u_int64_t u_int32_t u_int16_t u_int8_t
syn keyword cType in_addr_t fd_set sigset_t

" Arbor containers
syn keyword cType btree_t btree_iter_t fifo_t hash_t hash_iter_t heap_t
syn keyword cType lru_t lru_iter_t itree_t pair_t ptrie_t ptrie_node_t slist_t
syn keyword cType vector_t vector_iter_t

"Arbor lib
syn keyword cType arena_t pool_t prefix_t Timer

" Misc Arbor
syn keyword cType gmap_t iblock_t irmap_t tmfact_t networks_t prmap_t sql_t
