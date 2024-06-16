pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{
    .inherits = em.Import.@"em.hal/McuI",
});

pub const BusyWait = em.Import.@"ti.mcu.cc23xx/BusyWait";
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
        // -------- HFXTAL --------
        // CKMDSetTargetIrefTrim(HFXT_TARGET_IREF_MAX)
        var hfxttarg = reg(hal.CKMD_BASE + hal.CKMD_O_HFXTTARG).* & ~hal.CKMD_HFXTTARG_IREF_M;
        hfxttarg |= (8 << hal.CKMD_HFXTTARG_IREF_S) & hal.CKMD_HFXTTARG_IREF_M;
        reg(hal.CKMD_BASE + hal.CKMD_O_HFXTTARG).* = hfxttarg;

        reg(hal.CKMD_BASE + hal.CKMD_O_AMPCFG1).* &= ~hal.CKMD_AMPCFG1_INTERVAL_M;
        reg(hal.CKMD_BASE + hal.CKMD_O_LDOCTL).* =
            hal.CKMD_LDOCTL_SWOVR | hal.CKMD_LDOCTL_STARTCTL | hal.CKMD_LDOCTL_START | hal.CKMD_LDOCTL_EN;
        BusyWait.wait(100);
        reg(hal.CKMD_BASE + hal.CKMD_O_LDOCTL).* =
            hal.CKMD_LDOCTL_SWOVR | hal.CKMD_LDOCTL_HFXTLVLEN | hal.CKMD_LDOCTL_EN;
        reg(hal.CKMD_BASE + hal.CKMD_O_AMPADCCTL).* =
            hal.CKMD_AMPADCCTL_SWOVR | hal.CKMD_AMPADCCTL_PEAKDETEN_ENABLE | hal.CKMD_AMPADCCTL_ADCEN_ENABLE;
        BusyWait.wait(100);
        reg(hal.CKMD_BASE + hal.CKMD_O_ICLR).* = hal.CKMD_ICLR_ADCBIASUPD;
        reg(hal.CKMD_BASE + hal.CKMD_O_AMPADCCTL).* |= hal.CKMD_AMPADCCTL_SARSTRT;
        reg(hal.CKMD_BASE + hal.CKMD_O_AMPADCCTL).* &= ~hal.CKMD_AMPADCCTL_SARSTRT;
        while (!((reg(hal.CKMD_BASE + hal.CKMD_O_RIS).* & hal.CKMD_RIS_ADCBIASUPD_M) == hal.CKMD_RIS_ADCBIASUPD)) {}
        reg(hal.CKMD_BASE + hal.CKMD_O_AMPADCCTL).* &= ~(hal.CKMD_AMPADCCTL_SWOVR_M | hal.CKMD_AMPADCCTL_ADCEN_M);
        reg(hal.CKMD_BASE + hal.CKMD_O_HFTRACKCTL).* |= hal.CKMD_HFTRACKCTL_EN_M | hal.CKMD_HFTRACKCTL_REFCLK_HFXT;
        reg(hal.CKMD_BASE + hal.CKMD_O_HFXTCTL).* |= hal.CKMD_HFXTCTL_EN | hal.CKMD_HFXTCTL_HPBUFEN;
        while ((reg(hal.CKMD_BASE + hal.CKMD_O_RIS).* & hal.CKMD_RIS_AMPSETTLED) == 0) {}
        // continuous amp measurement
        reg(hal.CKMD_BASE + hal.CKMD_O_AMPADCCTL).* =
            hal.CKMD_AMPADCCTL_SWOVR | hal.CKMD_AMPADCCTL_PEAKDETEN_ENABLE |
            hal.CKMD_AMPADCCTL_ADCEN_ENABLE | hal.CKMD_AMPADCCTL_SRCSEL_PEAK |
            hal.CKMD_AMPADCCTL_SARSTRT;

        // LFXTAL
        reg(hal.CKMD_BASE + hal.CKMD_O_LFINCOVR).* = 0x001E8480 | hal.CKMD_LFINCOVR_OVERRIDE_M;
        reg(hal.CKMD_BASE + hal.CKMD_O_LFCLKSEL).* = hal.CKMD_LFCLKSEL_MAIN_LFXT;
        reg(hal.CKMD_BASE + hal.CKMD_O_LFXTCTL).* = hal.CKMD_LFXTCTL_EN;
        reg(hal.CKMD_BASE + hal.CKMD_O_IMSET).* = hal.CKMD_IMSET_HFXTFAULT | hal.CKMD_IMSET_TRACKREFLOSS | hal.CKMD_IMASK_LFCLKGOOD;
        // LFOSC
        //reg(hal.CKMD_BASE + hal.CKMD_O_TRIM1).* |= hal.CKMD_TRIM1_NABIAS_LFOSC;
        //reg(hal.CKMD_BASE + hal.CKMD_O_LFCLKSEL).* = hal.CKMD_LFCLKSEL_MAIN_LFOSC;
        //reg(hal.CKMD_BASE + hal.CKMD_O_LFOSCCTL).* = hal.CKMD_LFOSCCTL_EN;
        //reg(hal.CKMD_BASE + hal.CKMD_O_LFINCCTL).* &= ~hal.CKMD_LFINCCTL_PREVENTSTBY_M;
        //reg(hal.CKMD_BASE + hal.CKMD_O_IMSET).* = hal.CKMD_IMASK_LFCLKGOOD;
        // no cache
        reg(hal.CLKCTL_BASE + hal.CLKCTL_O_IDLECFG).* = 1;
        reg(hal.VIMS_BASE + hal.VIMS_O_CCHCTRL).* = 0;
    }
};
