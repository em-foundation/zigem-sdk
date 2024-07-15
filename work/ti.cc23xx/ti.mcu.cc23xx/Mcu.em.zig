pub const em = @import("../../.gen/em.zig");
pub const em__U = em.Module(@This(), .{
    .inherits = em.import.@"em.hal/McuI",
});

pub const BusyWait = em.import.@"ti.mcu.cc23xx/BusyWait";
pub const Debug = em.import.@"em.lang/Debug";

pub const EM__HOST = struct {
    //
};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    pub fn startup() void {
        Debug.startup();
        //        // cc23xx already running at 48MHz after reset
        //        // the following code is strictly not needed for level A
        //        reg(hal.CKMD_BASE + hal.CKMD_O_TRIM1).* |= hal.CKMD_TRIM1_NABIAS_LFOSC;
        //        reg(hal.CKMD_BASE + hal.CKMD_O_LFCLKSEL).* = hal.CKMD_LFCLKSEL_MAIN_LFOSC;
        //        reg(hal.CKMD_BASE + hal.CKMD_O_LFOSCCTL).* = hal.CKMD_LFOSCCTL_EN;
        //        reg(hal.CKMD_BASE + hal.CKMD_O_LFINCCTL).* &= ~hal.CKMD_LFINCCTL_PREVENTSTBY_M;
        //        reg(hal.CKMD_BASE + hal.CKMD_O_IMSET).* = hal.CKMD_IMASK_LFCLKGOOD;

        // -------- HFXTAL --------
        // CKMDSetTargetIrefTrim(HFXT_TARGET_IREF_MAX)
        em.@"%%[a:]"(3);
        em.@"%%[a+]"();
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
        reg(hal.CKMD_BASE + hal.CKMD_O_HFXTCTL).* |= hal.CKMD_HFXTCTL_EN;
        reg(hal.CKMD_BASE + hal.CKMD_O_HFTRACKCTL).* |= hal.CKMD_HFTRACKCTL_EN_M | hal.CKMD_HFTRACKCTL_REFCLK_HFXT;
        // LFXTAL
        // reg(hal.CKMD_BASE + hal.CKMD_O_LFINCOVR).* = 0x001E8480 | hal.CKMD_LFINCOVR_OVERRIDE_M;
        reg(hal.CKMD_BASE + hal.CKMD_O_LFCLKSEL).* = hal.CKMD_LFCLKSEL_MAIN_LFXT;
        reg(hal.CKMD_BASE + hal.CKMD_O_LFXTCTL).* = hal.CKMD_LFXTCTL_EN;
        reg(hal.CKMD_BASE + hal.CKMD_O_IMSET).* = hal.CKMD_IMSET_HFXTFAULT | hal.CKMD_IMSET_TRACKREFLOSS | hal.CKMD_IMASK_LFCLKGOOD;
        // LFOSC
        //reg(hal.CKMD_BASE + hal.CKMD_O_TRIM1).* |= hal.CKMD_TRIM1_NABIAS_LFOSC;
        //reg(hal.CKMD_BASE + hal.CKMD_O_LFCLKSEL).* = hal.CKMD_LFCLKSEL_MAIN_LFOSC;
        //reg(hal.CKMD_BASE + hal.CKMD_O_LFOSCCTL).* = hal.CKMD_LFOSCCTL_EN;
        //reg(hal.CKMD_BASE + hal.CKMD_O_LFINCCTL).* &= ~hal.CKMD_LFINCCTL_PREVENTSTBY_M;
        //reg(hal.CKMD_BASE + hal.CKMD_O_IMSET).* = hal.CKMD_IMASK_LFCLKGOOD;

        while ((reg(hal.CKMD_BASE + hal.CKMD_O_RIS).* & hal.CKMD_RIS_AMPSETTLED) == 0) {}
        // continuous amp measurement
        reg(hal.CKMD_BASE + hal.CKMD_O_AMPADCCTL).* =
            hal.CKMD_AMPADCCTL_SWOVR | hal.CKMD_AMPADCCTL_PEAKDETEN_ENABLE |
            hal.CKMD_AMPADCCTL_ADCEN_ENABLE | hal.CKMD_AMPADCCTL_SRCSEL_PEAK |
            hal.CKMD_AMPADCCTL_SARSTRT;
        // LF clock monitoring -- TODO very long startup ???
        // reg(hal.CKMD_BASE + hal.CKMD_O_LFMONCTL).* = hal.CKMD_LFMONCTL_EN;
        // reg(hal.PMCTL_BASE + hal.PMCTL_O_RSTCTL).* |= hal.PMCTL_RSTCTL_LFLOSS_ARMED;

        reg(hal.CLKCTL_BASE + hal.CLKCTL_O_IDLECFG).* = 1;
        reg(hal.VIMS_BASE + hal.VIMS_O_CCHCTRL).* = 0;
        em.@"%%[a-]"();
    }
};
