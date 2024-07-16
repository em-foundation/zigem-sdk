pub const em = @import("../../.gen/em.zig");
pub const em__U = em.module(@This(), .{
    .host_only = true,
});

pub const EM__HOST = struct {
    //
    pub fn em__generateH() void {
        genArmStartup();
        genStartup();
    }

    fn genArmStartup() void {
        const txt =
            \\#define __EM_BOOT_FLASH__ 0
            \\
            \\#include <stdbool.h>
            \\#include <stdint.h>
            \\
            \\extern uint32_t __bss_addr__;
            \\extern uint32_t __bss_size__;
            \\extern uint32_t __code_addr__;
            \\extern uint32_t __code_load__;
            \\extern uint32_t __code_size__;
            \\extern uint32_t __data_addr__;
            \\extern uint32_t __data_load__;
            \\extern uint32_t __data_size__;
            \\extern uint32_t __global_pointer__;
            \\extern uint32_t __stack_top__;
            \\
            \\extern void main();
            \\extern bool __is_warm();
            \\
            \\typedef struct {
            \\    unsigned int* codeLoad;
            \\    unsigned int* codeAddr;
            \\    unsigned int* bssAddr;
            \\    unsigned int bssSize;
            \\} __em_desc_t;
            \\
            \\extern void __attribute__((section(".start"), noreturn)) em__start() {
            \\
            \\    if (!__is_warm()) {
            \\        uint32_t *src;
            \\        uint32_t *dst;
            \\        volatile uint32_t sz;
            \\        sz = (uint32_t)&__bss_size__;
            \\        dst = &__bss_addr__;
            \\        asm("nop");
            \\        asm("nop");
            \\        asm("nop");
            \\        for (uint32_t i = 0; i < sz; i++) {     // TODO -- while (sz--) not working
            \\            dst[i] = 0;
            \\        }
            \\        sz = (uint32_t)&__data_size__;
            \\        src = &__data_load__;
            \\        dst = &__data_addr__;
            \\        for (uint32_t i = 0; i < sz; i++) {
            \\            dst[i] = src[i];
            \\        }
            \\#if __EM_BOOT_FLASH__ == 1
            \\        sz = (uint32_t)&__code_size__;
            \\        src = &__code_load__;
            \\        dst = &__code_addr__;
            \\        for (uint32_t i = 0; i < sz; i++) {
            \\            dst[i] = src[i];
            \\        }
            \\#endif
            \\    }
            \\
            \\    main();
            \\    __builtin_unreachable();
            \\}
            \\
            \\#if __EM_BOOT_FLASH__ == 1
            \\extern const void*  __attribute__((section(".start_vec"))) __em_start_vec[] = {
            \\    (void*)&__stack_top__ ,
            \\    (void*)em__start,
            \\};
            \\#endif
        ;
        em.writeFile(em.out_root, "arm-startup.c", txt);
    }

    fn genStartup() void {
        const txt =
            \\#include <stdbool.h>
            \\#include <stdint.h>
            \\
            \\#include "intr.c"
            \\
            \\#include "arm-startup.c"
            \\
            \\extern void main();
            \\
            \\bool __is_warm() {
            \\    return false;
            \\}
            \\
            \\extern const uint32_t __ccfg[] __attribute__((section(".ccfg"), used)) = {
            \\    0xFFFFFFFF, 0x00000000, 0x00000000, 0x00000000,
            \\    0xFFFFFFFF, 0xFFFFFFFF, 0xAAAAAAAA, 0x0000000F,
            \\    0xFFFFFFFF, 0xFFFFFFFF, 0x00000000, 0xFFFFFFFF,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x00000000, 0x00000000, 0x00000000, 0x00000000,
            \\    0x0000A55A, 0x03020101, 0x150D0805, 0x36E4D76D,
            \\    0xDF31F4EB, 0xEE15AE95, 0xE48EBA03, 0xD83FC6C4,
            \\    0x5E673F45, 0x01C2D774, 0xE558902C, 0x00000000,
            \\};
        ;
        em.writeFile(em.out_root, "startup.c", txt);
    }
};
