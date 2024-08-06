pub const em = @import("../../.gen/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    handler: em.Param(em.Fxn(Handler)),
};

pub const BusyWait = em.import.@"ti.mcu.cc23xx/BusyWait";
pub const Idle = em.import.@"ti.mcu.cc23xx/Idle";
pub const IntrVec = em.import.@"em.arch.arm/IntrVec";
pub const RadioConfig = em.import.@"ti.radio.cc23xx/RadioConfig";
pub const RfFifo = em.import.@"ti.radio.cc23xx/RfFifo";
pub const RfFreq = em.import.@"ti.radio.cc23xx/RfFreq";
pub const RfPatch = em.import.@"ti.radio.cc23xx/RfPatch";
pub const RfPower = em.import.@"ti.radio.cc23xx/RfPower";
pub const RfRegs = em.import.@"ti.radio.cc23xx/RfRegs";
pub const RfTrim = em.import.@"ti.radio.cc23xx/RfTrim";
pub const RfXtal = em.import.@"ti.radio.cc23xx/RfXtal";

pub const Handler = struct {};

pub const Mode = enum { IDLE, TX, CW };

pub const EM__HOST = struct {
    //
    pub fn em__constructH() void {
        IntrVec.useIntrH("LRFD_IRQ0");
    }

    pub fn bindHandlerH(h: em.Fxn(Handler)) void {
        em__C.handler.set(h);
    }
};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    const BLE_CHAN = 37;
    const BLE_FREQ = 2_402_000_000;

    var cur_mode: Mode = .IDLE;

    pub fn em__startup() void {
        Idle.waitOnly(.SET);
    }

    fn disable() void {
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
        RfXtal.disable();
    }

    fn enable() void {
        em.@"%%[c+]"();
        RfXtal.enable();
        em.@"%%[c-]"();
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

    fn enable2() void {
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_MSGBOX).* = 0;
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_INIT).* = hal.LRFDPBE_INIT_MDMF_M | hal.LRFDPBE_INIT_TOPSM_M;
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_ENABLE).* = hal.LRFDPBE_ENABLE_MDMF_M | hal.LRFDPBE_ENABLE_TOPSM_M;
        reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_INIT).* = hal.LRFDMDM_INIT_TXRXFIFO_M | hal.LRFDMDM_INIT_TOPSM_M;
        reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_ENABLE).* = hal.LRFDMDM_ENABLE_TXRXFIFO_M | hal.LRFDMDM_ENABLE_TOPSM_M;
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_INIT).* = hal.LRFDRFE_INIT_TOPSM_M;
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_ENABLE).* = hal.LRFDRFE_ENABLE_TOPSM_M;
        hal.NVIC_EnableIRQ(hal.LRFD_IRQ0_IRQn);
    }

    pub fn setup(mode: Mode, freq: u32) void {
        cur_mode = mode;
        if (mode == .IDLE) {
            disable();
            return;
        }
        enable();
        RfPatch.loadAll();
        RfRegs.setup();
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_RSSI).* = 127;
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_FIFOCMDADD).* = em.@"<>"(u16, ((hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCMD) & 0x0FFF) >> 2);
        RfTrim.apply();
        switch (RadioConfig.phy) {
            .BLE_1M => {
                reg(hal.LRFDPBE32_BASE + hal.LRFDPBE32_O_MDMSYNCA).* = 0x8E89BED6;
                reg(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_CRCINITL).* = (0x555555 << 8);
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_EXTRABYTES).* = 6; // stat + rssi + timestamp
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_OWNADRL).* = 0xAAAA;
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_OWNADRM).* = 0xBBBB;
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_OWNADRH).* = 0xCCCC;
                // ADVCFG, FILTPOLICY, RPAMODE, RPACONNECT, FL1MASK, FL2MASK = 0
                // OPCFG = 0
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_WHITEINIT).* = BLE_CHAN | 0x40;
            },
            .PROP_250K => {
                var cfg_val: u32 = 0;
                switch (mode) {
                    .CW => {
                        cfg_val =
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
                    },
                    .TX => {
                        reg(hal.LRFDPBE32_BASE + hal.LRFDPBE32_O_MDMSYNCA).* = updateSyncWord(0x930B_51DE);
                        cfg_val =
                            (0 << hal.PBE_GENERIC_RAM_OPCFG_TXINFINITE_S) |
                            (0 << hal.PBE_GENERIC_RAM_OPCFG_TXPATTERN_S) |
                            (2 << hal.PBE_GENERIC_RAM_OPCFG_TXFCMD_S) |
                            (0 << hal.PBE_GENERIC_RAM_OPCFG_START_S) |
                            // (1 << hal.PBE_GENERIC_RAM_OPCFG_FS_NOCAL_S) |
                            // (1 << hal.PBE_GENERIC_RAM_OPCFG_FS_KEEPON_S) |
                            (0 << hal.PBE_GENERIC_RAM_OPCFG_RXREPEATOK_S) |
                            (0 << hal.PBE_GENERIC_RAM_OPCFG_NEXTOP_S) |
                            (1 << hal.PBE_GENERIC_RAM_OPCFG_SINGLE_S) |
                            (0 << hal.PBE_GENERIC_RAM_OPCFG_IFSPERIOD_S) |
                            (0 << hal.PBE_GENERIC_RAM_OPCFG_RFINTERVAL_S);
                    },
                    .IDLE => {},
                }
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_OPCFG).* = em.@"<>"(u16, cfg_val);
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_NESB).* = (hal.PBE_GENERIC_RAM_NESB_NESBMODE_OFF);
            },
            else => unreachable,
        }
        enable2();
        const freq2: u32 = if (freq != 0) freq else switch (RadioConfig.phy) {
            .BLE_1M => BLE_FREQ,
            .PROP_250K => 2_440_000_000,
            else => 0,
        };
        RfFreq.program(freq2);
        RfPower.program(5);
    }

    pub fn startCw() void {
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_PATTERN).* = 0;
        reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_MODCTRL).* |= hal.LRFDMDM_MODCTRL_TONEINSERT_M;
        reg(hal.LRFDDBELL_BASE + hal.LRFDDBELL_O_IMASK0).* |= 0x00008001; // error done
        while (reg(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_MSGBOX).* == 0) {}
        const time = reg(hal.SYSTIM_BASE + hal.SYSTIM_O_TIME250N).*;
        reg(hal.SYSTIM_BASE + hal.SYSTIM_O_CH2CC).* = time + 1000;
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_API).* = hal.PBE_GENERIC_REGDEF_API_OP_TX;
    }

    pub fn startTx(word_buf: []const u32) void {
        //em.@"%%[>]"(reg(hal.CKMD_BASE + hal.CKMD_O_HFXTSTAT).*);
        _ = RfFifo.prepare();
        RfFifo.write(word_buf);
        reg(hal.LRFDDBELL_BASE + hal.LRFDDBELL_O_IMASK0).* |= 0x00008001; // done | error
        while (reg(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_MSGBOX).* == 0) {}
        reg(hal.SYSTIM_BASE + hal.SYSTIM_O_CH2CC).* = reg(hal.SYSTIM_BASE + hal.SYSTIM_O_TIME250N).*;
        const op = switch (RadioConfig.phy) {
            .BLE_1M => hal.PBE_BLE5_REGDEF_API_OP_ADV,
            .PROP_250K => hal.PBE_GENERIC_REGDEF_API_OP_TX,
            else => unreachable,
        };
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_API).* = op;

        //asm volatile ("bkpt");

        em.@"%%[a+]"();
        waitDone();
        disable();
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

    fn waitDone() void {
        Idle.waitOnly(.SET);
        while (cur_mode != .IDLE) {
            Idle.exec();
        }
        Idle.waitOnly(.CLR);
    }

    export fn LRFD_IRQ0_isr() void {
        if (em.hosted) return;
        const mis = reg(hal.LRFDDBELL_BASE + hal.LRFDDBELL_O_MIS0).*;
        reg(hal.LRFDDBELL_BASE + hal.LRFDDBELL_O_ICLR0).* = mis;
        em.@"%%[a-]"();
        cur_mode = .IDLE;
        if ((mis & 0x8000) != 0) {
            em.@"%%[>]"(em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_ENDCAUSE).*);
            em.fail();
        }
        hal.NVIC_ClearPendingIRQ(hal.LRFD_IRQ0_IRQn);
    }
};
