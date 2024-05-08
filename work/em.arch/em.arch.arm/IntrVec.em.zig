pub const EM__SPEC = null;

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const EM__HOST = null;

var a_name_tab = em__unit.array("a_name_tab", ?[]const u8);
var a_used_tab = em__unit.array("a_used_tab", []const u8);

pub fn addIntrH(name: ?[]const u8) void {
    a_name_tab.addElem(name);
}

pub fn useIntrH(name: []const u8) void {
    a_used_tab.addElem(name);
}

pub fn em__initH() void {
    const core_intrs = [_]?[]const u8{
        "NMI",
        "HardFault",
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        "SVCall",
        null,
        null,
        "PendSV",
        "SysTick",
    };
    for (core_intrs) |n| {
        addIntrH(n);
    }
}

pub fn em__generateH() void {
    var sbuf = em.StringH{};
    sbuf.add(
        \\#include <stdbool.h>
        \\#include <stdint.h>
        \\
        \\typedef void( *intfunc )( void );
        \\typedef union { intfunc fxn; void* ptr; } intvec_elem;
        \\
        \\extern uint32_t __stack_top__;
        \\extern void em__start( void );
        \\const intvec_elem  __attribute__((section(".intvec"))) __vector_table[] = {
        \\    { .ptr = (void*)&__stack_top__ },
        \\    { .fxn = em__start },
        \\
        \\     0,
        \\     0,
        \\     0,
        \\     0,
        \\     0,
        \\     0,
        \\     0,
        \\     0,
        \\     0,
        \\     0,
        \\     0,
        \\     0,
        \\     0,
        \\     0,
        \\};
    );
    em.writeFile(em.out_root, "intr.c", sbuf.get());
}

pub const EM__TARG = null;

pub fn em__startup() void {
    // ^^SCB->VTOR = (uint32_t)(&__vector_table)^^
}

export fn DEFAULT_isr() void {
    em.fail();
}
