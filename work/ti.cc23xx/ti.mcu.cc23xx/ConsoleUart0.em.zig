pub const EM__SPEC = {};

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{
    .inherits = em.Import.@"em.hal/ConsoleUartI",
});

pub const x_TxPin = em__unit.Proxy("TxPin", em.Import.@"em.hal/GpioI");

pub const EM__HOST = {};

pub const EM__TARG = {};

const hal = em.hal;
const REG = em.REG;
const TxPin = x_TxPin.unwrap();

pub fn em__startup() void {
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
    while ((REG(hal.UART0_BASE + hal.UART_O_FR).* & hal.UART_FR_BUSY) != 0) {}
}

pub fn put(data: u8) void {
    REG(hal.UART0_BASE + hal.UART_O_DR).* = data;
    flush();
}
