const em = @import("../../.gen/em.zig");

const Hal = em.Unit.@"ti.mcu.cc23xx/Hal";
const BusyWait = em.Unit.@"ti.mcu.cc23xx/BusyWait";

const REG = em.REG;

pub fn @"em$run"() void {
    const pin = 15;
    const mask = (1 << pin);
    REG(Hal.GPIO_BASE + Hal.GPIO_O_DOESET31_0).* = mask;
    REG(Hal.IOC_BASE + Hal.IOC_O_IOC0 + pin * 4).* &= ~Hal.IOC_IOC0_INPEN;
    for (0..10) |_| {
        BusyWait.wait(100000);
        REG(Hal.GPIO_BASE + Hal.GPIO_O_DOUTTGL31_0).* = mask;
    }
    em.halt();
}
