const std = @import("std");

const em = @import("../../.gen/em.zig");
const me = @This();

pub const em__unit = em.UnitSpec{
    .kind = .module,
    .upath = "ti.mcu.cc23xx/Hal",
    .self = me,
};

pub usingnamespace @import("hal/hw_memmap.zig");
pub usingnamespace @import("hal/hw_ckmd.zig");
pub usingnamespace @import("hal/hw_clkctl.zig");
pub usingnamespace @import("hal/hw_gpio.zig");
pub usingnamespace @import("hal/hw_ioc.zig");
pub usingnamespace @import("hal/hw_uart.zig");
