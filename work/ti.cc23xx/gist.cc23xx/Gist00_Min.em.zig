pub const EM__SPEC = {};

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const BoardC = em.Import.@"em__distro/BoardC";

pub const EM__HOST = {};

pub const EM__TARG = {};

const Hal: type = BoardC.Hal;
const REG = em.REG;

pub fn em__run() void {
    const pin = 15;
    const mask = (1 << pin);
    REG(Hal.GPIO_BASE + Hal.GPIO_O_DOESET31_0).* = mask;
    REG(Hal.IOC_BASE + Hal.IOC_O_IOC0 + pin * 4).* &= ~Hal.IOC_IOC0_INPEN;
    REG(Hal.GPIO_BASE + Hal.GPIO_O_DOUTSET31_0).* = mask;
}
