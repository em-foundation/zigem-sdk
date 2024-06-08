pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const RfPatch = em.Import.@"ti.radio.cc23xx/RfPatch";
pub const RfRegs = em.Import.@"ti.radio.cc23xx/RfRegs";
pub const RfTrim = em.Import.@"ti.radio.cc23xx/RfTrim";

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
        // apply trim
        RfTrim.apply();
        // skip enable REFSYS
        reg(hal.LRFDPBE32_BASE + hal.LRFDPBE32_O_MDMSYNCA).* = updateSyncWord(0x930B_51DE);

        //    uint32_t opCfgVal =
        //        (0 << PBE_GENERIC_RAM_OPCFG_TXINFINITE_S) |
        //        (0 << PBE_GENERIC_RAM_OPCFG_TXPATTERN_S) |
        //        (2 << PBE_GENERIC_RAM_OPCFG_TXFCMD_S) |
        //        (0 << PBE_GENERIC_RAM_OPCFG_START_S) |
        //        (1 << PBE_GENERIC_RAM_OPCFG_FS_NOCAL_S) |
        //        (1 << PBE_GENERIC_RAM_OPCFG_FS_KEEPON_S) |
        //        (0 << PBE_GENERIC_RAM_OPCFG_RXREPEATOK_S) |
        //        (0 << PBE_GENERIC_RAM_OPCFG_RXREPEATNOK_S) |
        //        (0 << PBE_GENERIC_RAM_OPCFG_NEXTOP_S) |
        //        (1 << PBE_GENERIC_RAM_OPCFG_SINGLE_S) |
        //        (0 << PBE_GENERIC_RAM_OPCFG_IFSPERIOD_S) |
        //        (0 << PBE_GENERIC_RAM_OPCFG_RFINTERVAL_S);
        //    HWREGH_WRITE_LRF(LRFD_BUFRAM_BASE + PBE_GENERIC_RAM_O_OPCFG) = opCfgVal;
        //    HWREGH_WRITE_LRF(LRFD_BUFRAM_BASE + PBE_GENERIC_RAM_O_NESB) = (PBE_GENERIC_RAM_NESB_NESBMODE_OFF);
    }

    fn updateSyncWord(syncWord: u32) u32 {
        var syncWordOut: u32 = undefined;
        if ((em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_PKTCFG).* & hal.PBE_GENERIC_RAM_PKTCFG_HDRORDER_M) != 0) {
            reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_PHAOUT0).* = syncWord & 0x0000FFFF;
            syncWordOut = reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_PHAOUT0BR).* << 16;
            reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_PHAOUT0).* = syncWord >> 16;
            syncWordOut |= reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_PHAOUT0BR).*;
            const syncWordLen = ((reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_DEMSWQU0).* & hal.LRFDMDM_DEMSWQU0_REFLEN_M) + 1);
            syncWordOut >>= @as(u5, @intCast(32 - syncWordLen));
        } else {
            syncWordOut = syncWord;
        }
        return syncWordOut;
    }
};
