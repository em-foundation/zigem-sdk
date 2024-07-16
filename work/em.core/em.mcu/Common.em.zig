pub const em = @import("../../.gen/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    BusyWait: em.Proxy(em.import.@"em.hal/BusyWaitI"),
    ConsoleUart: em.Proxy(em.import.@"em.hal/ConsoleUartI"),
    GlobalInterrupts: em.Proxy(em.import.@"em.hal/GlobalInterruptsI"),
    Idle: em.Proxy(em.import.@"em.hal/IdleI"),
    Mcu: em.Proxy(em.import.@"em.hal/McuI"),
    MsCounter: em.Proxy(em.import.@"em.hal/MsCounterI"),
    UsCounter: em.Proxy(em.import.@"em.hal/UsCounterI"),
};

pub const EM__HOST = struct {
    pub const BusyWait = em__C.BusyWait.ref();
    pub const ConsoleUart = em__C.ConsoleUart.ref();
    pub const GlobalInterrupts = em__C.GlobalInterrupts.ref();
    pub const Idle = em__C.Idle.ref();
    pub const Mcu = em__C.Mcu.ref();
    pub const MsCounter = em__C.MsCounter.ref();
    pub const UsCounter = em__C.UsCounter.ref();
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
