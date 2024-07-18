pub const em = @import("../../.gen/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    em__upath: []const u8,
};

pub const BusyWait = em.import.@"ti.mcu.cc23xx/BusyWait";

pub const EM__HOST = struct {};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    pub fn disable() void {}

    pub fn enable() void {
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
        reg(hal.CKMD_BASE + hal.CKMD_O_HFXTCTL).* |= hal.CKMD_HFXTCTL_EN;
        reg(hal.CKMD_BASE + hal.CKMD_O_HFTRACKCTL).* |= hal.CKMD_HFTRACKCTL_EN_M | hal.CKMD_HFTRACKCTL_REFCLK_HFXT;
        // continuous amp measurement
        while ((reg(hal.CKMD_BASE + hal.CKMD_O_RIS).* & hal.CKMD_RIS_AMPSETTLED) == 0) {}
        reg(hal.CKMD_BASE + hal.CKMD_O_AMPADCCTL).* =
            hal.CKMD_AMPADCCTL_SWOVR | hal.CKMD_AMPADCCTL_PEAKDETEN_ENABLE |
            hal.CKMD_AMPADCCTL_ADCEN_ENABLE | hal.CKMD_AMPADCCTL_SRCSEL_PEAK |
            hal.CKMD_AMPADCCTL_SARSTRT;
        // LF clock monitoring -- TODO very long startup ???
        reg(hal.CKMD_BASE + hal.CKMD_O_LFMONCTL).* = hal.CKMD_LFMONCTL_EN;
        reg(hal.PMCTL_BASE + hal.PMCTL_O_RSTCTL).* |= hal.PMCTL_RSTCTL_LFLOSS_ARMED;
    }
};
