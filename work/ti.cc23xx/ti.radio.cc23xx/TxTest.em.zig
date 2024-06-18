pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const AppLed = em.Import.@"em__distro/BoardC".AppLed;
pub const Common = em.Import.@"em.mcu/Common";
pub const FiberMgr = em.Import.@"em.utils/FiberMgr";
pub const RfCtrl = em.Import.@"ti.radio.cc23xx/RfCtrl";
pub const RfFifo = em.Import.@"ti.radio.cc23xx/RfFifo";
pub const RfFreq = em.Import.@"ti.radio.cc23xx/RfFreq";
pub const RfPatch = em.Import.@"ti.radio.cc23xx/RfPatch";
pub const RfPower = em.Import.@"ti.radio.cc23xx/RfPower";
pub const RfRegs = em.Import.@"ti.radio.cc23xx/RfRegs";
pub const RfTrim = em.Import.@"ti.radio.cc23xx/RfTrim";

pub const EM__HOST = struct {};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    var data = [_]u32{ 0x0203000F, 0x000A0001, 0x04030201, 0x08070605, 0x00000009 };

    pub fn em__run() void {
        doTx();
    }

    fn doTx() void {
        RfPatch.loadAll();
        RfRegs.setup();
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_RSSI).* = 127;
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_FIFOCMDADD).* = ((hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCMD) & 0x0FFF) >> 2;
        RfTrim.apply();
        reg(hal.LRFDPBE32_BASE + hal.LRFDPBE32_O_MDMSYNCA).* = updateSyncWord(0x930B_51DE);
        const opCfgVal: u32 =
            (0 << hal.PBE_GENERIC_RAM_OPCFG_TXINFINITE_S) |
            (0 << hal.PBE_GENERIC_RAM_OPCFG_TXPATTERN_S) |
            (2 << hal.PBE_GENERIC_RAM_OPCFG_TXFCMD_S) |
            (0 << hal.PBE_GENERIC_RAM_OPCFG_START_S) |
            (1 << hal.PBE_GENERIC_RAM_OPCFG_FS_NOCAL_S) |
            (1 << hal.PBE_GENERIC_RAM_OPCFG_FS_KEEPON_S) |
            (0 << hal.PBE_GENERIC_RAM_OPCFG_RXREPEATOK_S) |
            (0 << hal.PBE_GENERIC_RAM_OPCFG_RXREPEATNOK_S) |
            (0 << hal.PBE_GENERIC_RAM_OPCFG_NEXTOP_S) |
            (1 << hal.PBE_GENERIC_RAM_OPCFG_SINGLE_S) |
            (0 << hal.PBE_GENERIC_RAM_OPCFG_IFSPERIOD_S) |
            (0 << hal.PBE_GENERIC_RAM_OPCFG_RFINTERVAL_S);
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_OPCFG).* = opCfgVal;
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_NESB).* = (hal.PBE_GENERIC_RAM_NESB_NESBMODE_OFF);
        // program frequency
        RfFreq.program(2_440_000_000);
        RfPower.program(5);
        RfCtrl.enable();
        _ = RfFifo.prepare();
        RfFifo.write(&data);
        // enable interrupts
        reg(hal.LRFDDBELL_BASE + hal.LRFDDBELL_O_IMASK0).* |= 0x81; // done | error
        // wait for top FSM
        asm volatile ("bkpt");
        while (reg(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_MSGBOX).* == 0) {}
        // exec cmd
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_API).* = hal.PBE_GENERIC_REGDEF_API_OP_TX;
        Common.GlobalInterrupts.enable();
        Common.Idle.exec();
    }

    fn prepareFifo() u32 {
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCMD).* = (hal.LRFDPBE_FCMD_DATA_TXFIFO_RESET >> hal.LRFDPBE_FCMD_DATA_S);
        var fcfg0 = reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG0).*;
        fcfg0 &= ~em.@"<>"(u32, hal.LRFDPBE_FCFG0_TXADEAL_M);
        fcfg0 |= hal.LRFDPBE_FCFG0_TXACOM_M;
        return reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_TXFWRITABLE).*;
    }

    fn updateSyncWord(syncWord: u32) u32 {
        var syncWordOut: u32 = undefined;
        if ((em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_PKTCFG).* & hal.PBE_GENERIC_RAM_PKTCFG_HDRORDER_M) != 0) {
            reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_PHAOUT0).* = syncWord & 0x0000FFFF;
            syncWordOut = reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_PHAOUT0BR).* << 16;
            reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_PHAOUT0).* = syncWord >> 16;
            syncWordOut |= reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_PHAOUT0BR).*;
            const syncWordLen = ((reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_DEMSWQU0).* & hal.LRFDMDM_DEMSWQU0_REFLEN_M) + 1);
            syncWordOut >>= em.@"<>"(u5, 32 - syncWordLen);
        } else {
            syncWordOut = syncWord;
        }
        return syncWordOut;
    }
};
