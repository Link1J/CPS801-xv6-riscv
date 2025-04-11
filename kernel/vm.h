struct page_info {
    uint va;
    uint pa;
    struct page_info *next;
    struct page_info *prev;
    int in_swap;
    uint swap_offset;
    struct proc *proc;      // Process owning the page

};

void free_page_info(struct page_info *pi);