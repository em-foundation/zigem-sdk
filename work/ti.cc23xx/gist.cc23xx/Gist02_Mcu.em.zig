pub const EM__SPEC = null;

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const BusyWait = em.Import.@"scratch.cc23xx/BusyWait";
pub const Mcu = em.Import.@"scratch.cc23xx/Mcu";

pub const EM__HOST = null;

pub const EM__TARG = null;

const hal = em.hal;
const reg = em.reg;

pub fn em__startup() void {
    Mcu.startup();
}

pub fn em__run() void {
    const pin = 15;
    const mask = (1 << pin);
    reg(hal.GPIO_BASE + hal.GPIO_O_DOESET31_0).* = mask;
    reg(hal.IOC_BASE + hal.IOC_O_IOC0 + pin * 4).* &= ~hal.IOC_IOC0_INPEN;
    for (0..10) |_| {
        BusyWait.wait(100000);
        reg(hal.GPIO_BASE + hal.GPIO_O_DOUTTGL31_0).* = mask;
    }
}
