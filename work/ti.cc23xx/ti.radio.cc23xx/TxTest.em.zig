pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const RfPatch = em.Import.@"ti.radio.cc23xx/RfPatch";
pub const RfRegs = em.Import.@"ti.radio.cc23xx/RfRegs";

pub const EM__HOST = struct {};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    pub fn em__run() void {
        setup();
    }

    fn loadPatch(dst: u32, src: []const u32) void {
        @memcpy(@as([*]u32, @ptrFromInt(dst)), src);
    }

    fn setup() void {
        // configure radio intrs 0,1,2
        // skip temperature config
        // enable all clocks
        reg(hal.LRFDDBELL_BASE + hal.LRFDDBELL_O_CLKCTL).* =
            hal.LRFDDBELL_CLKCTL_BUFRAM_M |
            hal.LRFDDBELL_CLKCTL_DSBRAM_M |
            hal.LRFDDBELL_CLKCTL_RFERAM_M |
            hal.LRFDDBELL_CLKCTL_MCERAM_M |
            hal.LRFDDBELL_CLKCTL_PBERAM_M |
            hal.LRFDDBELL_CLKCTL_RFE_M |
            hal.LRFDDBELL_CLKCTL_MDM_M |
            hal.LRFDDBELL_CLKCTL_PBE_M;
        // enable high-perf clock buffer
        reg(hal.CKMD_BASE + hal.CKMD_O_HFXTCTL).* |= hal.CKMD_HFXTCTL_HPBUFEN;
        // load patches
        loadPatch(hal.LRFD_MCERAM_BASE, RfPatch.LRF_MCE_binary_genfsk[0..]);
        loadPatch(hal.LRFD_PBERAM_BASE, RfPatch.LRF_PBE_binary_generic[0..]);
        loadPatch(hal.LRFD_RFERAM_BASE, RfPatch.LRF_RFE_binary_genfsk[0..]);
        // setup rfregs
        RfRegs.setup();
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_RSSI).* = 127;
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_FIFOCMDADD).* = ((hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCMD) & 0x0FFF) >> 2;
    }
};

//
