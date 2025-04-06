struct page_info; 

// Global LRU list
extern struct page_info *lru_head;  // Head of the LRU list
extern struct page_info *lru_tail;  // Tail of the LRU list

// Function declarations for LRU management
void insert_into_lru(struct page_info *page);
void remove_from_lru(struct page_info *page);
void print_lru_list(void);  
void evict_page(void);
struct page_info *find_page_info(uint va);


