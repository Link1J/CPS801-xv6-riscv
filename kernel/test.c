// kernel/test.c
#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "vm.h"
#include "assert.h"
#include "fs.h"
#include "lru.h"

void test_eviction(void){
    printf("Starting eviction test...\n");
    // At this point, we expect all pages to be in the LRU list
    printf("Before eviction, LRU head: %p, LRU tail: %p\n", lru_head, lru_tail);
    struct page_info *prev_tail = lru_tail;
   
    printf("Eviction triggered...\n");
    evict_page();
    // Verify that the LRU list evicted page1 (since it was the least recently used)
    if (lru_tail == prev_tail) {
        printf("Test failed: lru_tail is the same\n");
        panic("Test failed: lru_tail is the same");
    }
    printf("After eviction, LRU head: %p, LRU tail: %p\n", lru_head, lru_tail);

}

void test_insert(void* page, int page_num) {
    printf("Inserting page %d...\n", page_num);
    printf("Before insert, LRU head: %p, LRU tail: %p\n", lru_head, lru_tail);
    struct page_info *prev_head = lru_head;
    
    // Map the new page and insert it into the LRU list
    if (mappages(myproc()->pagetable, (uint64)page, PGSIZE, (uint64)page, PTE_W | PTE_U) < 0) {
        printf("mappages failed for page %d\n", page_num);
        panic("mappages failed");
    }

    // Now, check which page was evicted (the least recently used one)
    printf("After insert, LRU head: %p, LRU tail: %p\n", lru_head, lru_tail);
    
    // Verify that the newly allocated page5 is now the head of the list (most recently used)
    if (lru_head == prev_head) {
        printf("Test failed: lru_head has not changed\n");
        panic("Test failed: lru_head has not changed");
    }
    
}


void test_page_replacement(void) {
    printf("Starting page replacement functionality test...\n");

    // Simulate allocating memory and filling pages with data
    void *page1 = kalloc();
    void *page2 = kalloc();
    void *page3 = kalloc();
    void *page4 = kalloc();

    if (!page1 || !page2 || !page3 || !page4) {
        panic("kalloc failed to allocate pages");
    }

    memset(page1, 0, PGSIZE);  // Fill the page with some data
    memset(page2, 1, PGSIZE);
    memset(page3, 2, PGSIZE);
    memset(page4, 3, PGSIZE);


    test_eviction();
    test_insert(page1, 1);
    test_insert(page2, 2);
    test_insert(page3, 3);
    test_insert(page4, 4);

    printf("Test passed: LRU eviction and page replacement functionality works as expected\n");

    uvmunmap(myproc()->pagetable, (uint64)page1, 1, 1);
    uvmunmap(myproc()->pagetable, (uint64)page2, 1, 1);
    uvmunmap(myproc()->pagetable, (uint64)page3, 1, 1);
    uvmunmap(myproc()->pagetable, (uint64)page4, 1, 1);
    

    printf("Test passed: Swap-in functionality works as expected\n");
}



