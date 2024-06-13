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
        // enable HFXTAL
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
        reg(hal.CKMD_BASE + hal.CKMD_O_HFXTCTL).* |= hal.CKMD_HFXTCTL_EN | hal.CKMD_HFXTCTL_HPBUFEN;
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
