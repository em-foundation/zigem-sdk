const em = @import("../em.zig");
const hal = @import("../hal.zig");
const std = @import("std");

const REG = em.REG;

pub fn startup() void {
    REG(hal.CKMD_BASE + hal.CKMD_O_TRIM1).* |= hal.CKMD_TRIM1_NABIAS_LFOSC;
    REG(hal.CKMD_BASE + hal.CKMD_O_LFCLKSEL).* = hal.CKMD_LFCLKSEL_MAIN_LFOSC;
    REG(hal.CKMD_BASE + hal.CKMD_O_LFOSCCTL).* = hal.CKMD_LFOSCCTL_EN;
    REG(hal.CKMD_BASE + hal.CKMD_O_LFINCCTL).* &= ~hal.CKMD_LFINCCTL_PREVENTSTBY_M;
    REG(hal.CKMD_BASE + hal.CKMD_O_IMSET).* = hal.CKMD_IMASK_LFCLKGOOD;
}
