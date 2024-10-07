pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

// TODO -- add other singleton em.hal proxies

pub const BusyWaitI = em.import.@"em.hal/BusyWaitI";
pub const ConsoleUartI = em.import.@"em.hal/ConsoleUartI";
pub const GlobalInterruptsI = em.import.@"em.hal/GlobalInterruptsI";
pub const IdleI = em.import.@"em.hal/IdleI";
pub const McuI = em.import.@"em.hal/McuI";
pub const MsCounterI = em.import.@"em.hal/MsCounterI";
pub const UptimerI = em.import.@"em.hal/UptimerI";
pub const UsCounterI = em.import.@"em.hal/UsCounterI";

pub const EM__CONFIG = struct {
    BusyWait: em.Proxy(BusyWaitI),
    ConsoleUart: em.Proxy(ConsoleUartI),
    GlobalInterrupts: em.Proxy(GlobalInterruptsI),
    Idle: em.Proxy(IdleI),
    Mcu: em.Proxy(McuI),
    MsCounter: em.Proxy(MsCounterI),
    Uptimer: em.Proxy(UptimerI),
    UsCounter: em.Proxy(UsCounterI),
};

pub const x_BusyWait = em__C.BusyWait;
pub const x_ConsoleUart = em__C.ConsoleUart;
pub const x_GlobalInterrupts = em__C.GlobalInterrupts;
pub const x_Idle = em__C.Idle;
pub const x_Mcu = em__C.Mcu;
pub const x_MsCounter = em__C.MsCounter;
pub const x_Uptimer = em__C.Uptimer;
pub const x_UsCounter = em__C.UsCounter;

pub const BusyWait = if (em.IS_META) .{} else em__C.BusyWait.get();
pub const ConsoleUart = if (em.IS_META) .{} else em__C.ConsoleUart.get();
pub const GlobalInterrupts = if (em.IS_META) .{} else em__C.GlobalInterrupts.get();
pub const Idle = if (em.IS_META) .{} else em__C.Idle.get();
pub const Mcu = if (em.IS_META) .{} else em__C.Mcu.get();
pub const MsCounter = if (em.IS_META) .{} else em__C.MsCounter.get();
pub const Uptimer = if (em.IS_META) .{} else em__C.Uptimer.get();
pub const UsCounter = if (em.IS_META) .{} else em__C.UsCounter.get();
