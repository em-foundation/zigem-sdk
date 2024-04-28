pub const EM__SPEC = {};

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const Hal = em.Import.@"ti.mcu.cc23xx/Hal";

pub const EM__HOST = {};

pub const EM__TARG = {};

pub fn startup() void {
    const REG = em.REG;
    // cc23xx already running at 48MHz after reset
    // the following code is strictly not needed for level A
    REG(Hal.CKMD_BASE + Hal.CKMD_O_TRIM1).* |= Hal.CKMD_TRIM1_NABIAS_LFOSC;
    REG(Hal.CKMD_BASE + Hal.CKMD_O_LFCLKSEL).* = Hal.CKMD_LFCLKSEL_MAIN_LFOSC;
    REG(Hal.CKMD_BASE + Hal.CKMD_O_LFOSCCTL).* = Hal.CKMD_LFOSCCTL_EN;
    REG(Hal.CKMD_BASE + Hal.CKMD_O_LFINCCTL).* &= ~Hal.CKMD_LFINCCTL_PREVENTSTBY_M;
    REG(Hal.CKMD_BASE + Hal.CKMD_O_IMSET).* = Hal.CKMD_IMASK_LFCLKGOOD;
}
