const em = @import("../../.gen/em.zig");

pub const em__unit = em.Unit{
    .kind = .module,
    .upath = "scratch.cc23xx/AppOut",
    .self = @This(),
};

pub const Hal = em.import.@"ti.mcu.cc23xx/Hal";
pub const TxPin = em__unit.Generate("AppLedPin", em.import.@"scratch.cc23xx/GpioT");

pub fn em__configureH() void {
    TxPin.c_pin.set(20);
}

const REG = em.REG;

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
