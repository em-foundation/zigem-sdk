pub const EM__SPEC = {};

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const EM__HOST = {};

pub const EM__TARG = {};

const hal = em.hal;
const REG = em.REG;

pub fn startup() void {
    // cc23xx already running at 48MHz after reset
    // the following code is strictly not needed for level A
    REG(hal.CKMD_BASE + hal.CKMD_O_TRIM1).* |= hal.CKMD_TRIM1_NABIAS_LFOSC;
    REG(hal.CKMD_BASE + hal.CKMD_O_LFCLKSEL).* = hal.CKMD_LFCLKSEL_MAIN_LFOSC;
    REG(hal.CKMD_BASE + hal.CKMD_O_LFOSCCTL).* = hal.CKMD_LFOSCCTL_EN;
    REG(hal.CKMD_BASE + hal.CKMD_O_LFINCCTL).* &= ~hal.CKMD_LFINCCTL_PREVENTSTBY_M;
    REG(hal.CKMD_BASE + hal.CKMD_O_IMSET).* = hal.CKMD_IMASK_LFCLKGOOD;
}
