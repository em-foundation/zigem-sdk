const em = @import("../em.zig");
const hal = @import("../hal.zig");
const std = @import("std");

const GpioMgr = @import("GpioMgr.zig");

const REG = em.REG;

const TxPin = GpioMgr.create(20);

pub fn @"em$startup"() void {
    REG(hal.CLKCTL_BASE + hal.CLKCTL_O_CLKENSET0).* = hal.CLKCTL_CLKENSET0_UART0;
    TxPin.makeOutput();
    TxPin.set();
    TxPin.functionSelect(2);
    REG(hal.UART0_BASE + hal.UART_O_CTL).* &= ~hal.UART_CTL_UARTEN;
    REG(hal.UART0_BASE + hal.UART_O_IBRD).* = 26; // 115200 baud
    REG(hal.UART0_BASE + hal.UART_O_FBRD).* = 3;
    REG(hal.UART0_BASE + hal.UART_O_LCRH).* = hal.UART_LCRH_WLEN_BITL8;
    REG(hal.UART0_BASE + hal.UART_O_CTL).* |= hal.UART_CTL_UARTEN;
}

pub fn flush() void {
    while (REG(hal.UART0_BASE + hal.UART_O_FR).* & hal.UART_FR_BUSY != 0) {}
}

pub fn put(data: u8) void {
    REG(hal.UART0_BASE + hal.UART_O_DR).* = data;
    // flush();
}
