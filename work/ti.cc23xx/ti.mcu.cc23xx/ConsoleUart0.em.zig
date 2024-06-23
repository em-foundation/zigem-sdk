pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{
    .inherits = em.Import.@"em.hal/ConsoleUartI",
});

pub const x_TxPin = em__unit.proxy("TxPin", em.Import.@"em.hal/GpioI");

pub const EM__HOST = struct {
    //
};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;
    const TxPin = x_TxPin.unwrap();

    pub fn em__startup() void {
        sleepLeave();
    }

    pub fn flush() void {
        while ((reg(hal.UART0_BASE + hal.UART_O_FR).* & hal.UART_FR_BUSY) != 0) {}
    }

    pub fn put(data: u8) void {
        reg(hal.UART0_BASE + hal.UART_O_DR).* = data;
        flush();
    }

    pub fn sleepEnter() void {
        reg(hal.CLKCTL_BASE + hal.CLKCTL_O_CLKENCLR0).* = hal.CLKCTL_CLKENCLR0_UART0;
        TxPin.reset();
    }

    pub fn sleepLeave() void {
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
};
