set smartindent
set noet
set sts=0
set sw=8
set ts=8
set tw=78
set noexpandtab

syn keyword     cType   u_char u_short u_int u_long off_t ssize_t key_t pid_t 
syn keyword     cType   int64_t int32_t int16_t int8_t 
syn keyword     cType   u_int64_t u_int32_t u_int16_t u_int8_t uc64_t
syn keyword     cType   in_addr_t

syn keyword	cType	hash_t hash_iter_t vector_t vector_iter_t btree_t
syn keyword	cType	iblock_t lru_t lru_iter_t mfact_t pool_t 
syn keyword	cType	slist_t fifo_t networks_t arena_t reg_t heap_t
