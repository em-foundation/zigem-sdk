pub const EM__SPEC = {};

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const TxPin = em__unit.Generate("AppLedPin", em.Import.@"scratch.cc23xx/GpioT");

pub const EM__HOST = {};

pub fn em__configureH() void {
    TxPin.c_pin.set(20);
}

pub const EM__TARG = {};

const hal = em.hal;
const reg = em.reg;

pub fn em__startup() void {
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

pub fn flush() void {
    while ((reg(hal.UART0_BASE + hal.UART_O_FR).* & hal.UART_FR_BUSY) != 0) {}
}

pub fn put(data: u8) void {
    reg(hal.UART0_BASE + hal.UART_O_DR).* = data;
    flush();
}
