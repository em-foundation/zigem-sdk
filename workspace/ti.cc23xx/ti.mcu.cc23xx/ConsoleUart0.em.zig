pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{ .inherits = ConsoleUartI });
pub const em__C = em__U.config(EM__CONFIG);

pub const ConsoleUartI = em.import2.@"em.hal/ConsoleUartI";
pub const Idle = em.import2.@"ti.mcu.cc23xx/Idle";
pub const GpioI = em.import2.@"em.hal/GpioI";

pub const EM__CONFIG = struct {
    TxPin: em.Proxy(GpioI),
};
pub const x_TxPin = em__C.TxPin;

// -------- META --------

pub fn em__configureH() void {
    Idle.addSleepEnterCbH(em__U.fxn("sleepEnter", Idle.SleepCbArg));
    Idle.addSleepLeaveCbH(em__U.fxn("sleepLeave", Idle.SleepCbArg));
}

// -------- TARG --------

const TxPin = em__C.TxPin.get();

const hal = em.hal;
const reg = em.reg;

pub fn em__startup() void {
    sleepLeave(.{});
}

pub fn flush() void {
    while ((reg(hal.UART0_BASE + hal.UART_O_FR).* & hal.UART_FR_BUSY) != 0) {}
}

pub fn put(data: u8) void {
    reg(hal.UART0_BASE + hal.UART_O_DR).* = data;
    flush();
}

pub fn sleepEnter(_: Idle.SleepCbArg) void {
    reg(hal.CLKCTL_BASE + hal.CLKCTL_O_CLKENCLR0).* = hal.CLKCTL_CLKENCLR0_UART0;
    TxPin.reset();
}

pub fn sleepLeave(_: Idle.SleepCbArg) void {
    reg(hal.CLKCTL_BASE + hal.CLKCTL_O_CLKENSET0).* = hal.CLKCTL_CLKENSET0_UART0;
    TxPin.makeOutput();
    TxPin.set();
    TxPin.functionSelect(2);
    reg(hal.UART0_BASE + hal.UART_O_CTL).* &= ~hal.UART_CTL_UARTEN;
    reg(hal.UART0_BASE + hal.UART_O_IBRD).* = 26; // 115200 baud
    reg(hal.UART0_BASE + hal.UART_O_FBRD).* = 3;
    reg(hal.UART0_BASE + hal.UART_O_LCRH).* = hal.UART_LCRH_WLEN_BITL8;
    reg(hal.UART0_BASE + hal.UART_O_CTL).* |= hal.UART_CTL_UARTEN;
}
