pub const EM__SPEC = {};

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{
    .inherits = em.Import.@"em.hal/ConsoleUartI",
});

pub const Hal = em.Import.@"ti.mcu.cc23xx/Hal";

pub const x_TxPin = em__unit.Proxy("TxPin", em.Import.@"em.hal/GpioI");

pub const EM__HOST = {};

pub const EM__TARG = {};

const REG = em.REG;
const TxPin = x_TxPin.unwrap();

pub fn em__startup() void {
    REG(Hal.CLKCTL_BASE + Hal.CLKCTL_O_CLKENSET0).* = Hal.CLKCTL_CLKENSET0_UART0;
    TxPin.makeOutput();
    TxPin.set();
    TxPin.functionSelect(2);
    REG(Hal.UART0_BASE + Hal.UART_O_CTL).* &= ~Hal.UART_CTL_UARTEN;
    REG(Hal.UART0_BASE + Hal.UART_O_IBRD).* = 26; // 115200 baud
    REG(Hal.UART0_BASE + Hal.UART_O_FBRD).* = 3;
    REG(Hal.UART0_BASE + Hal.UART_O_LCRH).* = Hal.UART_LCRH_WLEN_BITL8;
    REG(Hal.UART0_BASE + Hal.UART_O_CTL).* |= Hal.UART_CTL_UARTEN;
}

pub fn flush() void {
    while ((REG(Hal.UART0_BASE + Hal.UART_O_FR).* & Hal.UART_FR_BUSY) != 0) {}
}

pub fn put(data: u8) void {
    REG(Hal.UART0_BASE + Hal.UART_O_DR).* = data;
    flush();
}
