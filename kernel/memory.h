#ifndef MEMORY_H
#define MEMORY_H

#include <stdint.h>

// Page size and alignment
#define PAGE_SIZE 4096
#define PAGE_ALIGN(addr) (((addr) + PAGE_SIZE - 1) & ~(PAGE_SIZE - 1))

// Memory map
#define KERNEL_MEMORY_START 0x100000
#define KERNEL_MEMORY_END   0x200000
#define HEAP_MEMORY_START   0x200000
#define HEAP_MEMORY_END     0x400000

// Page directory and table entries
typedef struct {
    uint32_t present    : 1;
    uint32_t rw         : 1;
    uint32_t user       : 1;
    uint32_t pwt        : 1;
    uint32_t pcd        : 1;
    uint32_t accessed   : 1;
    uint32_t dirty      : 1;
    uint32_t pat        : 1;
    uint32_t global     : 1;
    uint32_t avail      : 3;
    uint32_t frame      : 20;
} page_entry_t;

typedef struct {
    page_entry_t entries[1024];
} page_table_t;

typedef struct {
    page_table_t* tables[1024];
    uint32_t tables_physical[1024];
    uint16_t refcount[1024];
} page_directory_t;

// Memory management functions
void memory_init(void);
void paging_init(void);
void heap_init(void);

// Page allocation
void* alloc_page(void);
void free_page(void* page);
void map_page(page_directory_t* dir, void* virt, void* phys, uint32_t flags);
void unmap_page(page_directory_t* dir, void* virt);

// Heap allocation
void* kmalloc(size_t size);
void kfree(void* ptr);

// Get current page directory
page_directory_t* get_current_directory(void);

// Switch page directory
void switch_directory(page_directory_t* dir);

#endif