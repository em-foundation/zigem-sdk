const em = @import("../../.gen/em.zig");

pub const @"em$unit" = em.UnitSpec{
    .kind = .module,
    .upath = "ti.mcu.cc23xx/Hal",
};

pub usingnamespace @import("hal/hw_memmap.zig");
pub usingnamespace @import("hal/hw_ckmd.zig");
pub usingnamespace @import("hal/hw_clkctl.zig");
pub usingnamespace @import("hal/hw_gpio.zig");
pub usingnamespace @import("hal/hw_ioc.zig");
pub usingnamespace @import("hal/hw_uart.zig");
