pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});
pub const em__C: *EM__CONFIG = em__unit.Config(EM__CONFIG);

pub const EM__CONFIG = struct {
    BusyWait: em.Proxy(em.Import.@"em.hal/BusyWaitI"),
    ConsoleUart: em.Proxy(em.Import.@"em.hal/ConsoleUartI"),
    GlobalInterrupts: em.Proxy(em.Import.@"em.hal/GlobalInterruptsI"),
    Idle: em.Proxy(em.Import.@"em.hal/IdleI"),
    Mcu: em.Proxy(em.Import.@"em.hal/McuI"),
    MsCounter: em.Proxy(em.Import.@"em.hal/MsCounterI"),
    UsCounter: em.Proxy(em.Import.@"em.hal/UsCounterI"),
};

pub const EM__HOST = struct {
    pub const x_BusyWait = em__C.BusyWait.ref();
    pub const x_ConsoleUart = em__C.ConsoleUart.ref();
    pub const x_GlobalInterrupts = em__C.GlobalInterrupts.ref();
    pub const x_Idle = em__C.Idle.ref();
    pub const x_Mcu = em__C.Mcu.ref();
    pub const x_MsCounter = em__C.MsCounter.ref();
    pub const x_UsCounter = em__C.UsCounter.ref();
};

pub const EM__TARG = struct {
    pub const BusyWait = em__C.BusyWait.unwrap();
    pub const ConsoleUart = em__C.ConsoleUart.unwrap();
    pub const GlobalInterrupts = em__C.GlobalInterrupts.unwrap();
    pub const Idle = em__C.Idle.unwrap();
    pub const Mcu = em__C.Mcu.unwrap();
    pub const MsCounter = em__C.MsCounter.unwrap();
    pub const UsCounter = em__C.UsCounter.unwrap();
};
