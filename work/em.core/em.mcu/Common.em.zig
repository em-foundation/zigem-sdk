pub const EM__SPEC = null;

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const x_BusyWait = em__unit.proxy("BusyWait", em.Import.@"em.hal/BusyWaitI");
pub const BusyWait = x_BusyWait.unwrap();

pub const x_ConsoleUart = em__unit.proxy("ConsoleUart", em.Import.@"em.hal/ConsoleUartI");
pub const ConsoleUart = x_ConsoleUart.unwrap();

pub const x_GlobalInterrupts = em__unit.proxy("GlobalInterrupts", em.Import.@"em.hal/GlobalInterruptsI");
pub const GlobalInterrupts = x_GlobalInterrupts.unwrap();

pub const x_Idle = em__unit.proxy("Idle", em.Import.@"em.hal/IdleI");
pub const Idle = x_Idle.unwrap();

pub const x_Mcu = em__unit.proxy("Mcu", em.Import.@"em.hal/McuI");
pub const Mcu = x_Mcu.unwrap();

pub const x_MsCounter = em__unit.proxy("MsCounter", em.Import.@"em.hal/MsCounterI");
pub const MsCounter = x_MsCounter.unwrap();

pub const EM__HOST = struct {};

pub const EM__TARG = struct {};
