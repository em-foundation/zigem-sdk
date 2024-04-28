pub const EM__SPEC = {};

pub const em = @import("../../.gen/em.zig");

pub const em__unit = em.Module(@This(), .{ .legacy = true });

pub usingnamespace @import("hal/hw_memmap.zig");
pub usingnamespace @import("hal/hw_ckmd.zig");
pub usingnamespace @import("hal/hw_clkctl.zig");
pub usingnamespace @import("hal/hw_gpio.zig");
pub usingnamespace @import("hal/hw_ioc.zig");
pub usingnamespace @import("hal/hw_uart.zig");

pub const EM__HOST = {};

pub const EM__TARG = {};
