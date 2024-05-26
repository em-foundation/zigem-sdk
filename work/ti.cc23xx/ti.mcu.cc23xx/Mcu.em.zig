pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{
    .inherits = em.Import.@"em.hal/McuI",
});

pub const Debug = em.Import.@"em.lang/Debug";

pub const EM__HOST = struct {
    //
};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    pub fn startup() void {
        Debug.startup();
        // cc23xx already running at 48MHz after reset
        // the following code is strictly not needed for level A
        reg(hal.CKMD_BASE + hal.CKMD_O_TRIM1).* |= hal.CKMD_TRIM1_NABIAS_LFOSC;
        reg(hal.CKMD_BASE + hal.CKMD_O_LFCLKSEL).* = hal.CKMD_LFCLKSEL_MAIN_LFOSC;
        reg(hal.CKMD_BASE + hal.CKMD_O_LFOSCCTL).* = hal.CKMD_LFOSCCTL_EN;
        reg(hal.CKMD_BASE + hal.CKMD_O_LFINCCTL).* &= ~hal.CKMD_LFINCCTL_PREVENTSTBY_M;
        reg(hal.CKMD_BASE + hal.CKMD_O_IMSET).* = hal.CKMD_IMASK_LFCLKGOOD;
        // no cache
        reg(hal.CLKCTL_BASE + hal.CLKCTL_O_IDLECFG).* = 1;
        reg(hal.VIMS_BASE + hal.VIMS_O_CCHCTRL).* = 0;
    }
};
