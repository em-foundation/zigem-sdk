pub const EM__SPEC = null;

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const EM__HOST = struct {};

pub const EM__TARG = struct {};

const hal = em.hal;
const reg = em.reg;

pub fn em__run() void {
    const pin = 15;
    const mask = (1 << pin);
    reg(hal.GPIO_BASE + hal.GPIO_O_DOESET31_0).* = mask;
    reg(hal.IOC_BASE + hal.IOC_O_IOC0 + pin * 4).* &= ~hal.IOC_IOC0_INPEN;
    reg(hal.GPIO_BASE + hal.GPIO_O_DOUTSET31_0).* = mask;
}
