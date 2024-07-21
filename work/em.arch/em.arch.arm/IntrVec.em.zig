pub const em = @import("../../.gen/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    name_tab: em.Table(?[]const u8, .RO),
    used_tab: em.Table([]const u8, .RO),
};

export fn DEFAULT_isr() void {
    if (em.hosted) return;
    em__U.scope().defaultIsr();
}

pub const EM__HOST = struct {
    //
    var name_tab = em__C.name_tab.ref();
    var used_tab = em__C.used_tab.ref();

    pub fn addIntrH(name: ?[]const u8) void {
        name_tab.add(name);
    }

    pub fn useIntrH(name: []const u8) void {
        used_tab.add(name);
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
        for (name_tab.items()) |n| {
            if (n == null) continue;
            sbuf.add(em.sprint("#define __{s}_isr _DEFAULT_isr\n", .{n.?}));
        }
        sbuf.add(
            \\
            \\extern void DEFAULT_isr( void );
            \\void _DEFAULT_isr( void ) {
            \\    DEFAULT_isr();
            \\}
            \\
            \\
        );
        //for (a_name_tab.unwrap()) |n| {
        //    if (n == null) continue;
        //    sbuf.add(em.sprint("#undef __{s}_isr\n", .{}));
        //    sbuf.add(em.sprint("void {s}_isr( void ) __attribute__((weak, alias(\"_DEFAULT_isr\")));\n", .{n.?}));
        //}
        sbuf.add("// used\n");
        for (used_tab.items()) |n| {
            sbuf.add(em.sprint(
                \\#undef __{s}_isr
                \\#define __{0s}_isr {0s}_isr
                \\void {0s}_isr( void ) __attribute__((weak, alias("_DEFAULT_isr")));
                \\
            , .{n}));
        }
        sbuf.add(
            \\
            \\#include <stdbool.h>
            \\#include <stdint.h>
            \\
            \\typedef void( *intfunc )( void );
            \\typedef union { intfunc fxn; void* ptr; } intvec_elem;
            \\
            \\extern uint32_t __stack_top__;
            \\extern void em__start( void );
            \\
            \\extern void DEFAULT_isr( void );
            \\
            \\const intvec_elem  __attribute__((section(".intvec"))) __vector_table[] = {
            \\    { .ptr = (void*)&__stack_top__ },
            \\    { .fxn = em__start },
            \\
        );
        for (name_tab.items()) |n| {
            const s = if (n == null) "0" else em.sprint("__{s}_isr", .{n.?});
            sbuf.add(em.sprint("    {s},\n", .{s}));
        }
        sbuf.add("};\n");
        em.writeFile(em.out_root, "intr.c", sbuf.get());
    }
};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    extern var __vector_table: u32;

    pub fn em__startup() void {
        hal.SCB.*.VTOR = @intFromPtr(&__vector_table);
    }

    pub fn defaultIsr() void {
        const vnum: u8 = @intCast(get_IPSR());
        em.@"%%[b:]"(3);
        em.@"%%[>]"(vnum);
        em.fail();
    }

    fn get_IPSR() u32 {
        const res: u32 = 0;
        asm volatile (
            \\mrs %[res], ipsr        
            :
            : [res] "r" (res),
            : "memory"
        );
        return res;
    }

    //    auto vecNum = <uint32>(^^__get_IPSR()^^)
    //    %%[b:4]
    //    %%[><uint8>vecNum]
    //    auto frame = <uint32[]>(^^__get_MSP()^^)
    //    %%[><uint32>&frame[0]]
    //    for auto i = 0; i < 8; i++
    //        %%[b]
    //        %%[>frame[i]]
    //    end
    //    fail

};
