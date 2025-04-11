// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

void freerange(void *pa_start, void *pa_end);

uint memcount[PHYSTOP/PGSIZE] = {0};

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  struct run *freelist;
} kmem;

void
kinit()
{
  initlock(&kmem.lock, "kmem");
  freerange(end, (void*)PHYSTOP);
}

void
freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char*)PGROUNDUP((uint64)pa_start);
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    kmemincref(p); // Trick kfree that the page is allocated
    kfree(p);
  }
}

// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  // Subtract 1 atomically, and return if people are still using the page
  uint count = __atomic_sub_fetch(memcount + PA2INDEX(pa), 1, __ATOMIC_SEQ_CST);
  if (count == 0xFFFFFFFF) {
    panic("Super free page");
  }
  if (count > 0) {
    return;
  }

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  r = (struct run*)pa;

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
  struct run *r;

  acquire(&kmem.lock);
  r = kmem.freelist;
  if(r)
  {
    kmem.freelist = r->next;
    // Inc ref, and panic if the ref count was not 0
    if (kmemincref(r) != 0) {
      panic("Attempted to reuse memory that was in use");
    }
  }
  release(&kmem.lock);

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
  return (void*)r;
}

// Add 1 atomically, and return the previous value
uint
kmemincref(void *pa)
{
  return __atomic_fetch_add(memcount + PA2INDEX(pa), 1, __ATOMIC_SEQ_CST);
}

// Read mem ref count
uint
kmemrefcount(void *pa) 
{
  return __atomic_load_n(memcount + PA2INDEX(pa), __ATOMIC_SEQ_CST);
}

int
kcow(pagetable_t pagetable, uint64 va)
{  
  uint64 va_page = PGROUNDDOWN(va);
  if (va_page >= MAXVA){
    return -1;
  }
  pte_t* pte = walk(pagetable, va_page, 0);
  if (pte == NULL) {
    return -1;
  }

  if (((*pte) & PTE_COW) == 0) {
    return 0;
  }

  uint64 pa = PTE2PA(*pte);
  uint count = kmemrefcount((void*)pa);
  if (count == 0) 
    panic("Attempting to copy free page");

  if (count == 1)
  {
    // there are no copys
    *pte = (*pte & ~(PTE_COW)) | PTE_W;
  }
  else 
  {
    // Copy page
    char* mem = kalloc();
    if (mem == NULL)
      panic("Failed to get new page for CoW page");
    memmove(mem, (void*)pa, PGSIZE);
    
    // Map new page
    uint flags = (PTE_FLAGS((uint64)*pte) & ~(PTE_COW)) | PTE_W;
    if (mappages(pagetable, va_page, PGSIZE, (uint64)mem, flags) != 0)
      panic("Failed to remap CoW page");
    
    // "Free" CoW page
    kfree((void*)pa);
  }
  return 1;
}