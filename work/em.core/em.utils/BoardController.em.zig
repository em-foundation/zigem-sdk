pub const EM__SPEC = {};

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const Common = em.Import.@"em.mcu/Common";

pub const x_Led = em__unit.Proxy("Led", em.Import.@"em.hal/LedI");
pub const x_Uart = em__unit.Proxy("Uart", em.Import.@"em.hal/ConsoleUartI");

pub const EM__HOST = {};

pub const EM__TARG = {};

pub fn em__reset() void {}

pub fn em__ready() void {}

pub fn em__fail() void {}

pub fn em__halt() void {}
