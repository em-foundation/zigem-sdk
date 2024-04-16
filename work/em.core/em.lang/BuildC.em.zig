const em = @import("../../.gen/em.zig");

pub const em__unit = em.UnitSpec{
    .kind = .composite,
    .upath = "em.lang/BuildC",
    .self = @This(),
};

pub const d_ = &em__decls;
pub var em__decls = em__unit.declare(struct {
    max: em.Config(u32) = em.Config(u32).initV(20),
    min: em.Config(u32) = em.Config(u32).initV(10),
});

pub fn em__generateH() void {}

fn genLinkerCmd() void {
    const fmt =
        \\MEMORY {{
        \\    DMEM : ORIGIN = 0x20000000, LENGTH = 0x00009000
        \\    IMEM : ORIGIN = 0x00000000, LENGTH = 0x00080000
        \\    FLASH_CCFG : ORIGIN = 0x4e020000, LENGTH = 0x00000800
        \\}}
        \\
        \\SECTIONS {{
        \\ 
        \\     __boot_flag__ = 0;
        \\
        \\    .text : {{
        \\         KEEP(*(.intvec))
        \\         *(.start)
        \\         *(.text .text.*)
        \\         . = ALIGN(., 4);
        \\    }} > IMEM
        \\ 
        \\    .const : {{
        \\        *(.rodata .rodata.* .constdata .constdata.*)
        \\        . = ALIGN(., 4);
        \\    }} > IMEM
        \\ 
        \\    __data_load_start__ = ALIGN(., 4);
        \\
        \\    .data : AT(__data_load_start__) {{
        \\        *(.data .data.* .sdata .sdata.*)
        \\        . = ALIGN(., 4);
        \\    }} > DMEM
        \\
        \\    .bss (NOLOAD): {{
        \\        *(.bss .bss.*)
        \\        *(.sbss .sbss.*)
        \\        . = ALIGN(., 4);
        \\    }} > DMEM
        \\ 
        \\    .ccfg : {{ KEEP(*(.ccfg)); . = 0x00000800; }} > FLASH_CCFG
        \\
        \\    __bss_addr__ = ADDR(.bss);
        \\    __bss_size__ = SIZEOF(.bss) / 4;
        \\    __code_addr__ = ADDR(.text);
        \\    __data_addr__ = ADDR(.data);
        \\    __data_load__ = LOADADDR(.data);
        \\    __data_size__ = SIZEOF(.data) / 4;
        \\    __code_load__ = ~0;
        \\    __code_size__ = ~0;
        \\    __global_pointer__ = __data_addr__ + 0x800;
        \\    __global_pointer$ = __global_pointer__;
        \\    __stack_top__ = 0x20000000 + 0x00009000;
        \\}}
    ;
    _ = em.sprint(fmt, .{});
}
