pub const em = @import("../../.gen/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    em__upath: []const u8,
};

pub const BusyWait = em.import.@"ti.mcu.cc23xx/BusyWait";
pub const IntrVec = em.import.@"em.arch.arm/IntrVec";
pub const Idle = em.import.@"ti.mcu.cc23xx/Idle";

pub const EM__HOST = struct {
    //
    pub fn em__constructH() void {
        IntrVec.useIntrH("CPUIRQ3");
    }
};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    const IREF_MAX = 8;
    const IREF_MIN = 3;

    var osc_ready: bool = undefined;

    pub fn em__startup() void {
        // Power_init
        reg(hal.CKMD_BASE + hal.CKMD_O_AMPCFG1).* &= ~hal.CKMD_AMPCFG1_INTERVAL_M;
        setIrefTrim(IREF_MAX);
        reg(hal.EVTSVT_BASE + hal.EVTSVT_O_CPUIRQ3SEL).* = hal.EVTSVT_CPUIRQ3SEL_PUBID_AON_CKM_COMB;
        hal.NVIC_EnableIRQ(hal.CPUIRQ3_IRQn);
    }

    pub fn disable() void {
        // adjust amplitude
        const stat = reg(hal.CKMD_BASE + hal.CKMD_O_AMPADCSTAT).*;
        const peak = (stat & hal.CKMD_AMPADCSTAT_PEAKRAW_M) >> hal.CKMD_AMPADCSTAT_PEAKRAW_S;
        const bias = (stat & hal.CKMD_AMPADCSTAT_BIAS_M) >> hal.CKMD_AMPADCSTAT_BIAS_S;
        const ampl: u32 = if (2 * peak > bias) 2 * peak - bias else 0;
        const trim: u32 = (reg(hal.CKMD_BASE + hal.CKMD_O_HFXTTARG).* & hal.CKMD_HFXTTARG_IREF_M) >> hal.CKMD_HFXTTARG_IREF_S;
        const adjust: i32 = if (ampl < 10 and trim < IREF_MAX) 1 else if (ampl > 16 and trim > IREF_MIN) -1 else 0;
        setIrefTrim(em.@"<>"(u32, em.@"<>"(i32, trim) + adjust));
        reg(hal.CKMD_BASE + hal.CKMD_O_HFXTCTL).* &= ~hal.CKMD_HFXTCTL_EN_M;
        reg(hal.CKMD_BASE + hal.CKMD_O_AMPADCCTL).* &= ~hal.CKMD_AMPADCCTL_SWOVR;
    }

    pub fn enable() void {
        em.@"%%[c+]"();
        // PowerCC23X0_startHFXT()
        reg(hal.CKMD_BASE + hal.CKMD_O_LDOCTL).* =
            hal.CKMD_LDOCTL_SWOVR | hal.CKMD_LDOCTL_STARTCTL | hal.CKMD_LDOCTL_START | hal.CKMD_LDOCTL_EN;
        BusyWait.wait(66);
        reg(hal.CKMD_BASE + hal.CKMD_O_LDOCTL).* =
            hal.CKMD_LDOCTL_SWOVR | hal.CKMD_LDOCTL_HFXTLVLEN | hal.CKMD_LDOCTL_EN;
        reg(hal.CKMD_BASE + hal.CKMD_O_AMPADCCTL).* =
            hal.CKMD_AMPADCCTL_SWOVR | hal.CKMD_AMPADCCTL_PEAKDETEN_ENABLE | hal.CKMD_AMPADCCTL_ADCEN_ENABLE;
        BusyWait.wait(6);
        reg(hal.CKMD_BASE + hal.CKMD_O_ICLR).* = hal.CKMD_ICLR_ADCBIASUPD;
        reg(hal.CKMD_BASE + hal.CKMD_O_AMPADCCTL).* |= hal.CKMD_AMPADCCTL_SARSTRT;
        reg(hal.CKMD_BASE + hal.CKMD_O_AMPADCCTL).* &= ~hal.CKMD_AMPADCCTL_SARSTRT;
        while (!((reg(hal.CKMD_BASE + hal.CKMD_O_RIS).* & hal.CKMD_RIS_ADCBIASUPD_M) == hal.CKMD_RIS_ADCBIASUPD)) {}
        reg(hal.CKMD_BASE + hal.CKMD_O_AMPADCCTL).* &= ~(hal.CKMD_AMPADCCTL_SWOVR_M | hal.CKMD_AMPADCCTL_ADCEN_M);
        reg(hal.CKMD_BASE + hal.CKMD_O_HFXTCTL).* |= hal.CKMD_HFXTCTL_EN;
        osc_ready = false;
        reg(hal.CKMD_BASE + hal.CKMD_O_ICLR).* = hal.CKMD_ICLR_AMPSETTLED | hal.CKMD_ICLR_LFCLKGOOD;
        reg(hal.CKMD_BASE + hal.CKMD_O_IMSET).* = hal.CKMD_IMSET_AMPSETTLED | hal.CKMD_IMSET_LFCLKGOOD;
        while (!osc_ready) Idle.pause();
        // PowerCC23X0_oscillatorISR
        //while ((reg(hal.CKMD_BASE + hal.CKMD_O_RIS).* & hal.CKMD_RIS_AMPSETTLED) == 0) {}
        reg(hal.CKMD_BASE + hal.CKMD_O_AMPADCCTL).* =
            hal.CKMD_AMPADCCTL_SWOVR | hal.CKMD_AMPADCCTL_PEAKDETEN_ENABLE |
            hal.CKMD_AMPADCCTL_ADCEN_ENABLE | hal.CKMD_AMPADCCTL_SRCSEL_PEAK |
            hal.CKMD_AMPADCCTL_SARSTRT;
        //while ((reg(hal.CKMD_BASE + hal.CKMD_O_RIS).* & hal.CKMD_MIS_LFCLKGOOD) == 0) {}
        reg(hal.CKMD_BASE + hal.CKMD_O_LFMONCTL).* = hal.CKMD_LFMONCTL_EN;
        reg(hal.PMCTL_BASE + hal.PMCTL_O_RSTCTL).* |= hal.PMCTL_RSTCTL_LFLOSS_ARMED;
        reg(hal.CKMD_BASE + hal.CKMD_O_ICLR).* = hal.CKMD_ICLR_AMPSETTLED | hal.CKMD_ICLR_LFCLKGOOD;
        reg(hal.CKMD_BASE + hal.CKMD_O_HFTRACKCTL).* |= hal.CKMD_HFTRACKCTL_EN_M;
        em.@"%%[c-]"();
    }

    fn setIrefTrim(iref: u32) void {
        var hfxttarg = reg(hal.CKMD_BASE + hal.CKMD_O_HFXTTARG).* & ~hal.CKMD_HFXTTARG_IREF_M;
        hfxttarg |= (iref << hal.CKMD_HFXTTARG_IREF_S) & hal.CKMD_HFXTTARG_IREF_M;
        reg(hal.CKMD_BASE + hal.CKMD_O_HFXTTARG).* = hfxttarg;
    }

    export fn CPUIRQ3_isr() void {
        if (em.hosted) return;
        hal.NVIC_ClearPendingIRQ(hal.CPUIRQ3_IRQn);
        const mis = reg(hal.CKMD_BASE + hal.CKMD_O_MIS).*;
        reg(hal.CKMD_BASE + hal.CKMD_O_ICLR).* = mis;
        reg(hal.CKMD_BASE + hal.CKMD_O_IMCLR).* = mis;
        osc_ready = (mis & hal.CKMD_MIS_AMPSETTLED) != 0;
        BusyWait.wait(1); // TODO -- needed for SRAM execution
    }
};
