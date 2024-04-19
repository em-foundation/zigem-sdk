const em = @import("../../.gen/em.zig");

pub const em__unit = em.UnitSpec{
    .kind = .module,
    .upath = "scratch.cc23xx/AppLedPin",
    .self = @This(),
};

pub const Hal = em.import.@"ti.mcu.cc23xx/Hal";

const pin: i16 = 15;
const mask = 1 << pin;

const REG = em.REG;

pub fn clear() void {
    REG(Hal.GPIO_BASE + Hal.GPIO_O_DOUTCLR31_0).* = mask;
}

pub fn makeOutput() void {
    REG(Hal.GPIO_BASE + Hal.GPIO_O_DOESET31_0).* = mask;
    REG(Hal.IOC_BASE + Hal.IOC_O_IOC0 + pin * 4).* &= ~Hal.IOC_IOC0_INPEN;
}

pub fn pinId() i16 {
    return pin;
}

pub fn set() void {
    REG(Hal.GPIO_BASE + Hal.GPIO_O_DOUTSET31_0).* = mask;
}

pub fn toggle() void {
    REG(Hal.GPIO_BASE + Hal.GPIO_O_DOUTTGL31_0).* = mask;
}
