pub const em = @import("../../zigem/gen/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    em__upath: []const u8,
};

pub const EM__HOST = struct {};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    pub fn disable() void {
        em.reg16(hal.LRFDPBE_BASE + hal.LRFDPBE_O_PDREQ).* = hal.LRFDPBE_PDREQ_TOPSMPDREQ_M;
        em.reg16(hal.LRFDPBE_BASE + hal.LRFDPBE_O_ENABLE).* = 0;
        em.reg16(hal.LRFDPBE_BASE + hal.LRFDPBE_O_PDREQ).* = 0;
        //
        em.reg16(hal.LRFDMDM_BASE + hal.LRFDMDM_O_PDREQ).* = hal.LRFDMDM_PDREQ_TOPSMPDREQ_M;
        em.reg16(hal.LRFDMDM_BASE + hal.LRFDMDM_O_ENABLE).* = 0;
        em.reg16(hal.LRFDMDM_BASE + hal.LRFDMDM_O_PDREQ).* = 0;
        //
        em.reg16(hal.LRFDRFE_BASE + hal.LRFDRFE_O_PDREQ).* = hal.LRFDRFE_PDREQ_TOPSMPDREQ_M;
        em.reg16(hal.LRFDRFE_BASE + hal.LRFDRFE_O_ENABLE).* = 0;
        em.reg16(hal.LRFDRFE_BASE + hal.LRFDRFE_O_PDREQ).* = 0;
        //
        em.reg16(hal.LRFDRFE32_BASE + hal.LRFDRFE32_O_ATSTREF).* &= em.@"<>"(u16, ~hal.LRFDRFE32_ATSTREF_BIAS_M);
    }

    pub fn enableClocks() void {
        reg(hal.CLKCTL_BASE + hal.CLKCTL_O_CLKENSET0).* = hal.CLKCTL_CLKENSET0_LRFD;
        while ((reg(hal.CLKCTL_BASE + hal.CLKCTL_O_CLKCFG0).* & hal.CLKCTL_CLKCFG0_LRFD_M) != hal.CLKCTL_CLKCFG0_LRFD_CLK_EN) {}
        reg(hal.PMUD_BASE + hal.PMUD_O_CTL).* = hal.PMUD_CTL_CALC_EN | hal.PMUD_CTL_MEAS_EN | hal.PMUD_CTL_HYST_EN_DIS;
        while ((reg(hal.PMUD_BASE + hal.PMUD_O_TEMPUPD).* & hal.PMUD_TEMPUPD_STA_M) != hal.PMUD_TEMPUPD_STA_M) {}
        reg(hal.LRFDDBELL_BASE + hal.LRFDDBELL_O_CLKCTL).* =
            hal.LRFDDBELL_CLKCTL_BUFRAM_M |
            hal.LRFDDBELL_CLKCTL_DSBRAM_M |
            hal.LRFDDBELL_CLKCTL_RFERAM_M |
            hal.LRFDDBELL_CLKCTL_MCERAM_M |
            hal.LRFDDBELL_CLKCTL_PBERAM_M |
            hal.LRFDDBELL_CLKCTL_RFE_M |
            hal.LRFDDBELL_CLKCTL_MDM_M |
            hal.LRFDDBELL_CLKCTL_PBE_M;
        reg(hal.CKMD_BASE + hal.CKMD_O_HFXTCTL).* |= hal.CKMD_HFXTCTL_HPBUFEN;
    }

    pub fn enableImages() void {
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_MSGBOX).* = 0;
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_INIT).* = hal.LRFDPBE_INIT_MDMF_M | hal.LRFDPBE_INIT_TOPSM_M;
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_ENABLE).* = hal.LRFDPBE_ENABLE_MDMF_M | hal.LRFDPBE_ENABLE_TOPSM_M;
        reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_INIT).* = hal.LRFDMDM_INIT_TXRXFIFO_M | hal.LRFDMDM_INIT_TOPSM_M;
        reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_ENABLE).* = hal.LRFDMDM_ENABLE_TXRXFIFO_M | hal.LRFDMDM_ENABLE_TOPSM_M;
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_INIT).* = hal.LRFDRFE_INIT_TOPSM_M;
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_ENABLE).* = hal.LRFDRFE_ENABLE_TOPSM_M;
    }
};
