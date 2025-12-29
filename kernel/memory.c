#include "memory.h"
#include "kernel.h"

// Kernel page directory
static page_directory_t kernel_directory;

// Current page directory
static page_directory_t* current_directory;

// Frame allocation bitmap
static uint32_t* frames;
static uint32_t n_frames;

// Heap state
static uint32_t heap_start;
static uint32_t heap_end;
static uint32_t heap_position;

#define INDEX_FROM_BIT(b) (b / 32)
#define OFFSET_FROM_BIT(b) (b % 32)

static void set_frame(uint32_t frame_addr) {
    uint32_t frame = frame_addr / PAGE_SIZE;
    uint32_t idx = INDEX_FROM_BIT(frame);
    uint32_t off = OFFSET_FROM_BIT(frame);
    frames[idx] |= (0x1 << off);
}

static void clear_frame(uint32_t frame_addr) {
    uint32_t frame = frame_addr / PAGE_SIZE;
    uint32_t idx = INDEX_FROM_BIT(frame);
    uint32_t off = OFFSET_FROM_BIT(frame);
    frames[idx] &= ~(0x1 << off);
}

static uint32_t test_frame(uint32_t frame_addr) {
    uint32_t frame = frame_addr / PAGE_SIZE;
    uint32_t idx = INDEX_FROM_BIT(frame);
    uint32_t off = OFFSET_FROM_BIT(frame);
    return (frames[idx] & (0x1 << off));
}

static uint32_t first_free_frame(void) {
    for (uint32_t i = 0; i < INDEX_FROM_BIT(n_frames); i++) {
        if (frames[i] != 0xFFFFFFFF) {
            for (uint32_t j = 0; j < 32; j++) {
                uint32_t test_bit = 0x1 << j;
                if (!(frames[i] & test_bit)) {
                    return i * 32 + j;
                }
            }
        }
    }
    return (uint32_t)-1;
}

void* alloc_frame(void) {
    uint32_t frame_index = first_free_frame();
    if (frame_index == (uint32_t)-1) {
        return NULL; // No free frames
    }
    
    set_frame(frame_index * PAGE_SIZE);
    return (void*)(frame_index * PAGE_SIZE);
}

void free_frame(void* frame_addr) {
    clear_frame((uint32_t)frame_addr);
}

void paging_init(void) {
    // Calculate number of frames
    uint32_t mem_end_page = 0x10000000; // 256MB for now
    n_frames = mem_end_page / PAGE_SIZE;
    frames = (uint32_t*)0x100000; // Temporary location
    
    // Clear frame bitmap
    for (uint32_t i = 0; i < INDEX_FROM_BIT(n_frames); i++) {
        frames[i] = 0;
    }
    
    // Create page directory
    for (uint32_t i = 0; i < 1024; i++) {
        kernel_directory.tables[i] = NULL;
        kernel_directory.tables_physical[i] = 0;
        kernel_directory.refcount[i] = 0;
    }
    
    // Map kernel memory (identity mapping for first 4MB)
    for (uint32_t i = 0; i < 1024; i++) {
        uint32_t frame = i * PAGE_SIZE;
        map_page(&kernel_directory, (void*)frame, (void*)frame, 0x03);
    }
    
    current_directory = &kernel_directory;
    switch_directory(&kernel_directory);
    
    // Enable paging
    uint32_t cr0;
    __asm__ volatile("mov %%cr0, %0" : "=r"(cr0));
    cr0 |= 0x80000000; // Set paging bit
    __asm__ volatile("mov %0, %%cr0" :: "r"(cr0));
}

void map_page(page_directory_t* dir, void* virt, void* phys, uint32_t flags) {
    uint32_t page_index = (uint32_t)virt / PAGE_SIZE;
    uint32_t table_index = page_index / 1024;
    
    // Create page table if it doesn't exist
    if (dir->tables[table_index] == NULL) {
        void* new_table = alloc_frame();
        dir->tables[table_index] = (page_table_t*)new_table;
        dir->tables_physical[table_index] = (uint32_t)new_table | flags | 0x01;
        
        // Clear the new page table
        for (uint32_t i = 0; i < 1024; i++) {
            ((page_entry_t*)new_table)[i].frame = 0;
            ((page_entry_t*)new_table)[i].present = 0;
            ((page_entry_t*)new_table)[i].rw = 1;
            ((page_entry_t*)new_table)[i].user = 0;
            ((page_entry_t*)new_table)[i].pwt = 0;
            ((page_entry_t*)new_table)[i].pcd = 0;
            ((page_entry_t*)new_table)[i].accessed = 0;
            ((page_entry_t*)new_table)[i].dirty = 0;
            ((page_entry_t*)new_table)[i].pat = 0;
            ((page_entry_t*)new_table)[i].global = 0;
            ((page_entry_t*)new_table)[i].avail = 0;
        }
    }
    
    // Map the page
    page_entry_t* page = &dir->tables[table_index]->entries[page_index % 1024];
    page->frame = (uint32_t)phys / PAGE_SIZE;
    page->present = 1;
    page->rw = (flags & 0x02) ? 1 : 0;
    page->user = (flags & 0x04) ? 1 : 0;
    page->pwt = (flags & 0x08) ? 1 : 0;
    page->pcd = (flags & 0x10) ? 1 : 0;
}

void switch_directory(page_directory_t* dir) {
    current_directory = dir;
    __asm__ volatile("mov %0, %%cr3" :: "r"(&dir->tables_physical));
}

page_directory_t* get_current_directory(void) {
    return current_directory;
}

void heap_init(void) {
    heap_start = HEAP_MEMORY_START;
    heap_end = HEAP_MEMORY_END;
    heap_position = heap_start;
}

void* kmalloc(size_t size) {
    // Align to 8-byte boundary
    size = (size + 7) & ~7;
    
    if (heap_position + size > heap_end) {
        return NULL; // Out of heap memory
    }
    
    void* ptr = (void*)heap_position;
    heap_position += size;
    return ptr;
}

void kfree(void* ptr) {
    // Simple heap - no free for now
    (void)ptr;
}

void memory_init(void) {
    terminal_writestring("Initializing memory management...\n");
    
    paging_init();
    terminal_writestring("Paging enabled\n");
    
    heap_init();
    terminal_writestring("Heap initialized\n");
    
    terminal_writestring("Memory management ready\n");
}