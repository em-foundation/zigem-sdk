pub const EM__SPEC = {};

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const x_BusyWait = em__unit.Proxy("BusyWait", em.Import.@"em.hal/BusyWaitI");
pub const BusyWait = x_BusyWait.unwrap();

pub const EM__HOST = {};

pub const EM__TARG = {};
