setlocal smartindent
setlocal noet
setlocal sts=0
setlocal sw=8
setlocal ts=8
setlocal tw=78
setlocal noexpandtab

syn keyword     cType   u_char u_short u_int u_long off_t ssize_t key_t pid_t 
syn keyword     cType   int64_t int32_t int16_t int8_t 
syn keyword     cType   u_int64_t u_int32_t u_int16_t u_int8_t uc64_t
syn keyword     cType   in_addr_t addr_t uint gpio_t
syn keyword     cType   u8 u16 u32 u64

syn keyword	cType	hash_t hash_iter_t vector_t vector_iter_t btree_t
syn keyword	cType	iblock_t lru_t lru_iter_t mfact_t pool_t 
syn keyword	cType	slist_t fifo_t networks_t arena_t reg_t heap_t
