const em = @import("../em.zig");
const hal = @import("../hal.zig");

const REG = em.REG;

pub const pin: i16 = 15;
const mask = 1 << pin;

pub fn clear() void {
    REG(hal.GPIO_BASE + hal.GPIO_O_DOUTCLR31_0).* = mask;
}

pub fn makeOutput() void {
    REG(hal.GPIO_BASE + hal.GPIO_O_DOESET31_0).* = mask;
    REG(hal.IOC_BASE + hal.IOC_O_IOC0 + pin * 4).* &= ~hal.IOC_IOC0_INPEN;
}

pub fn pinId() i16 {
    return pin;
}

pub fn set() void {
    REG(hal.GPIO_BASE + hal.GPIO_O_DOUTSET31_0).* = mask;
}

pub fn toggle() void {
    REG(hal.GPIO_BASE + hal.GPIO_O_DOUTTGL31_0).* = mask;
}
