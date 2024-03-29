const em = @import("../em.zig");
const hal = @import("../hal.zig");
const BusyWait = @import("../scratch/BusyWait.zig");

const REG = em.REG;

pub fn @"em$run"() void {
    const pin = 15;
    const mask = (1 << pin);
    REG(hal.GPIO_BASE + hal.GPIO_O_DOESET31_0).* = mask;
    REG(hal.IOC_BASE + hal.IOC_O_IOC0 + pin * 4).* &= ~hal.IOC_IOC0_INPEN;
    for (0..10) |_| {
        BusyWait.wait(100000);
        REG(hal.GPIO_BASE + hal.GPIO_O_DOUTTGL31_0).* = mask;
    }
    em.halt();
}
