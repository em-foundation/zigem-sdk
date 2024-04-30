pub const EM__SPEC = {};

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const x_BusyWait = em__unit.Proxy("BusyWait", em.Import.@"em.hal/BusyWaitI");
pub const BusyWait = x_BusyWait.unwrap();

pub const x_ConsoleUart = em__unit.Proxy("ConsoleUart", em.Import.@"em.hal/ConsoleUartI");
pub const ConsoleUart = x_ConsoleUart.unwrap();

pub const x_GlobalInterrupts = em__unit.Proxy("GlobalInterrupts", em.Import.@"em.hal/GlobalInterruptsI");
pub const GlobalInterrupts = x_GlobalInterrupts.unwrap();

pub const x_Mcu = em__unit.Proxy("Mcu", em.Import.@"em.hal/McuI");
pub const Mcu = x_Mcu.unwrap();

pub const EM__HOST = {};

pub const EM__TARG = {};
