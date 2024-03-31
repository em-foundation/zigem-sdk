#include <stdbool.h>
#include <stdint.h>

extern uint32_t __bss_addr__;
extern uint32_t __bss_size__;
extern uint32_t __code_addr__;
extern uint32_t __code_load__;
extern uint32_t __code_size__;
extern uint32_t __data_addr__;
extern uint32_t __data_load__;
extern uint32_t __data_size__;
extern uint32_t __global_pointer__;
extern uint32_t __stack_top__;

extern void main();
extern bool __is_warm();

typedef struct {
    unsigned int* codeLoad;
    unsigned int* codeAddr;
    unsigned int* bssAddr;
    unsigned int bssSize;
} __em_desc_t;

extern void __attribute__((section(".start"))) __em_program_start() {

    if (!__is_warm()) {
        uint32_t *src;
        uint32_t *dst;
        volatile uint32_t sz;
        sz = (uint32_t)&__bss_size__;
        dst = &__bss_addr__;
        asm("nop");
        asm("nop");
        asm("nop");
        for (uint32_t i = 0; i < sz; i++) {     // TODO -- while (sz--) not working
            dst[i] = 0;
        }
        sz = (uint32_t)&__data_size__;
        src = &__data_load__;
        dst = &__data_addr__;
        for (uint32_t i = 0; i < sz; i++) {
            dst[i] = src[i];
        }
    }

    main();
}

#if __EM_BOOT_FLASH__ == 1
extern "C" const void*  __attribute__((section(".start_vec"))) __em_start_vec[] = {
    (void*)&__stack_top__ ,
    (void*)__em_program_start,
};
#endif

