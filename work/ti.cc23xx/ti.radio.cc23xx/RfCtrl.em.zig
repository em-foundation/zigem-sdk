pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const EM__HOST = struct {};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    pub fn disable() void {}

    pub fn enable() void {
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_MSGBOX).* = 0;
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_INIT).* = hal.LRFDPBE_INIT_MDMF_M | hal.LRFDPBE_INIT_TOPSM_M;
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_ENABLE).* = hal.LRFDPBE_ENABLE_MDMF_M | hal.LRFDPBE_ENABLE_TOPSM_M;
        reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_INIT).* = hal.LRFDMDM_INIT_TXRXFIFO_M | hal.LRFDMDM_INIT_TOPSM_M;
        reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_ENABLE).* = hal.LRFDMDM_ENABLE_TXRXFIFO_M | hal.LRFDMDM_ENABLE_TOPSM_M;
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_INIT).* = hal.LRFDRFE_INIT_TOPSM_M;
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_ENABLE).* = hal.LRFDRFE_ENABLE_TOPSM_M;
    }
};
