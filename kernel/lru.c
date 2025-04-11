#include "types.h"
#include "riscv.h"
#include "param.h"
#include "stat.h"
#include "spinlock.h"
#include "defs.h"
#include "proc.h"
#include "sleeplock.h"
#include "fs.h"
#include "buf.h"
#include "file.h"
#include "vm.h"
#include "lru.h"





// Initialize global pointers for the LRU list
struct page_info *lru_head = 0;  // Head of the LRU list
struct page_info *lru_tail = 0;  // Tail of the LRU list

// Insert a page at the head of the LRU list
void insert_into_lru(struct page_info *page) {
    if (lru_head) {
        lru_head->prev = page;
    }
    page->next = lru_head;
    page->prev = 0;
    lru_head = page;

    // If the list was empty, the new page becomes both the head and the tail
    if (lru_tail == 0) {
        lru_tail = page;
    }
}

// Remove a page from the LRU list
void remove_from_lru(struct page_info *page) {
    // Adjust pointers to remove the page from the list
    if (page->prev) {
        page->prev->next = page->next;
    } else {
        lru_head = page->next;
    }
    if (page->next) {
        page->next->prev = page->prev;
    } else {
        lru_tail = page->prev;
    }
    page->next = 0;
    page->prev = 0;
}

// Optional: Print the LRU list for debugging
void print_lru_list(void) {
    struct page_info *p = lru_head;
    while (p) {
        printf("Page: %p\n", p);
        p = p->next;
    }
}



void evict_page(void) {
    printf("Evicting page...\n");

    struct page_info *victim = lru_tail;

    // Search backward in LRU list for a page that is in memory and not already swapped
    while (victim && (victim->in_swap || victim->pa == 0)) {
        victim = victim->prev;
    }

    // If no suitable page found, just return
    if (victim == 0) {
        printf("evict_page: no suitable victim found\n");
        return;
    }

    // Swap out the selected victim
    swap_out_page(victim);
}
  
// Find the page_info for a given virtual address in the LRU list
struct page_info *find_page_info(uint va) {
    struct page_info *page = lru_head;  // Start at the head of the LRU list

    // Iterate through the LRU list
    while (page != NULL) {
        // Check if the virtual address matches
        if (page->va == va) {
            return page;  // Return the page_info struct if found
        }
        page = page->next;  // Move to the next page in the LRU list
    }

    // If no matching page_info found, return NULL
    return NULL;
}