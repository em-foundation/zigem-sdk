pub const em = @import("../../zigem/em.zig");
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

pub const EM__META = struct {
    pub const BusyWait = em__C.BusyWait;
    pub const ConsoleUart = em__C.ConsoleUart;
    pub const GlobalInterrupts = em__C.GlobalInterrupts;
    pub const Idle = em__C.Idle;
    pub const Mcu = em__C.Mcu;
    pub const MsCounter = em__C.MsCounter;
    pub const UsCounter = em__C.UsCounter;
};

pub const EM__TARG = struct {
    pub const BusyWait = em__C.BusyWait.get();
    pub const ConsoleUart = em__C.ConsoleUart.get();
    pub const GlobalInterrupts = em__C.GlobalInterrupts.get();
    pub const Idle = em__C.Idle.get();
    pub const Mcu = em__C.Mcu.get();
    pub const MsCounter = em__C.MsCounter.get();
    pub const UsCounter = em__C.UsCounter.get();
};
