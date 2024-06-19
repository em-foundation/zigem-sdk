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

    pub fn em__run() void {
        RfPatch.loadAll();
        RfRegs.setup();
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_RSSI).* = 127;
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_FIFOCMDADD).* = ((hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCMD) & 0x0FFF) >> 2;
        // apply trim
        RfTrim.apply();
        // skip enable REFSYS
        // no sync word
        // reg(hal.LRFDPBE32_BASE + hal.LRFDPBE32_O_MDMSYNCA).* = 0x930B_51DE;

        const opCfgVal: u32 =
            (1 << hal.PBE_GENERIC_RAM_OPCFG_TXINFINITE_S) |
            (1 << hal.PBE_GENERIC_RAM_OPCFG_TXPATTERN_S) |
            (0 << hal.PBE_GENERIC_RAM_OPCFG_TXFCMD_S) |
            (0 << hal.PBE_GENERIC_RAM_OPCFG_START_S) |
            // (1 << hal.PBE_GENERIC_RAM_OPCFG_FS_NOCAL_S) |
            // (1 << hal.PBE_GENERIC_RAM_OPCFG_FS_KEEPON_S) |
            (0 << hal.PBE_GENERIC_RAM_OPCFG_RXREPEATOK_S) |
            (0 << hal.PBE_GENERIC_RAM_OPCFG_NEXTOP_S) |
            (1 << hal.PBE_GENERIC_RAM_OPCFG_SINGLE_S) |
            (0 << hal.PBE_GENERIC_RAM_OPCFG_IFSPERIOD_S) |
            (0 << hal.PBE_GENERIC_RAM_OPCFG_RFINTERVAL_S);
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_OPCFG).* = opCfgVal;
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_NESB).* = (hal.PBE_GENERIC_RAM_NESB_NESBMODE_OFF);
        RfPower.program(5);
        // txWord
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_PATTERN).* = 0;
        // sendCw
        reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_MODCTRL).* |= hal.LRFDMDM_MODCTRL_TONEINSERT_M;
        RfCtrl.enable();
        RfFreq.program(2_440_000_000);
        // _ = RfFifo.prepare();
        // enable interrupts
        reg(hal.LRFDDBELL_BASE + hal.LRFDDBELL_O_IMASK0).* |= 0x20008001; // systim0 | error done
        // wait for top FSM
        while (reg(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_MSGBOX).* == 0) {}
        AppLed.on();
        Common.BusyWait.wait(100_000);
        AppLed.off();
        const time = reg(hal.SYSTIM_BASE + hal.SYSTIM_O_TIME250N).*;
        reg(hal.SYSTIM_BASE + hal.SYSTIM_O_CH2CC).* = time + 1000;
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_API).* = hal.PBE_GENERIC_REGDEF_API_OP_TX;
    }
};
