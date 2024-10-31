pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    handler: em.Param(em.Fxn(Handler)),
};

pub const BusyWait = em.import.@"ti.mcu.cc23xx/BusyWait";
pub const Idle = em.import.@"ti.mcu.cc23xx/Idle";
pub const IntrVec = em.import.@"em.arch.arm/IntrVec";
pub const RadioConfig = em.import.@"ti.radio.cc23xx/RadioConfig";
pub const RfCtrl = em.import.@"ti.radio.cc23xx/RfCtrl";
pub const RfFifo = em.import.@"ti.radio.cc23xx/RfFifo";
pub const RfFreq = em.import.@"ti.radio.cc23xx/RfFreq";
pub const RfPatch = em.import.@"ti.radio.cc23xx/RfPatch";
pub const RfPower = em.import.@"ti.radio.cc23xx/RfPower";
pub const RfRegs = em.import.@"ti.radio.cc23xx/RfRegs";
pub const RfTrim = em.import.@"ti.radio.cc23xx/RfTrim";
pub const RfXtal = em.import.@"ti.radio.cc23xx/RfXtal";

pub const Handler = struct {};

pub const State = enum { IDLE, SETUP, READY, RX, TX, CS, CW };

pub const EM__META = struct {
    //
    pub fn em__constructM() void {
        IntrVec.useIntrM("LRFD_IRQ0");
    }
};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    var cur_state = State.IDLE;
    var rx_timeout = false;

    pub fn disable() void {
        setState(.IDLE);
        RfCtrl.disable();
        RfXtal.disable();
    }

    pub fn enable() void {
        setState(.SETUP);
        RfXtal.enable();
        RfCtrl.enableClocks();
        RfPatch.loadAll();
        RfXtal.waitReady();
        RfRegs.setup();
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_RSSI).* = 127;
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_FIFOCMDADD).* = em.as(u16, ((hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCMD) & 0x0FFF) >> 2);
        RfTrim.apply();
        switch (RadioConfig.phy) {
            .BLE_1M => {
                reg(hal.LRFDPBE32_BASE + hal.LRFDPBE32_O_MDMSYNCA).* = 0x8E89_BED6;
                reg(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_CRCINITL).* = (0x555555 << 8);
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_EXTRABYTES).* = 6; // stat + rssi + timestamp
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_OWNADRL).* = 0xAAAA;
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_OWNADRM).* = 0xBBBB;
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_OWNADRH).* = 0xCCCC;
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_ADVCFG).* = 0;
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_FILTPOLICY).* = 0;
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_RPACONNECT).* = 0;
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_RPACONNECT).* = 0;
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_FL1MASK).* = 0;
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_FL2MASK).* = 0;
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_OPCFG).* = 0;
            },
            .PROP_1M, .PROP_250K => {
                reg(hal.LRFDPBE32_BASE + hal.LRFDPBE32_O_MDMSYNCA).* = 0x7B8AD0C9; // scramble(0x930B_51DE);
            },
            .NONE => {},
        }
        setState(.READY);
    }

    fn freqFromChan(chan: u32) u32 {
        const BASE = 2_404_000_000;
        const SPACE = 2_000_000;
        switch (chan) {
            0...10 => return BASE + (chan * SPACE),
            11...36 => return BASE + (chan * SPACE) + SPACE,
            37 => return 2_402_000_000,
            38 => return 2_426_000_000,
            39 => return 2_480_000_000,
            else => unreachable,
        }
    }

    pub fn readPkt(pkt: []u8) []u8 {
        if (rx_timeout) return pkt[0..0];
        const sz = RfFifo.readPkt(pkt);
        return pkt[0..sz];
    }

    pub fn readRssi() i8 {
        if (rx_timeout) return 0;
        return switch (cur_state) {
            .CS => em.as(i8, reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_RSSI).* & hal.LRFDRFE_RSSI_VAL_M),
            else => em.as(i8, em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_LASTRSSI).*), // TODO + RSSI offset
        };
    }

    fn setState(s: State) void {
        // em.@"%%[a:]"(@intFromEnum(s));
        cur_state = s;
    }

    pub fn startCs(chan: u8, timeout: u16) void {
        setState(.CS);
        RfCtrl.enableImages();
        const cfg_val: u32 =
            (0 << hal.PBE_GENERIC_RAM_OPCFG_RXFILTEROP_S) |
            (1 << hal.PBE_GENERIC_RAM_OPCFG_RXINCLUDEHDR_S) |
            (1 << hal.PBE_GENERIC_RAM_OPCFG_RXREPEATNOK_S) |
            (0 << hal.PBE_GENERIC_RAM_OPCFG_START_S) |
            // (1 << hal.PBE_GENERIC_RAM_OPCFG_FS_NOCAL_S) |
            // (1 << hal.PBE_GENERIC_RAM_OPCFG_FS_KEEPON_S) |
            (1 << hal.PBE_GENERIC_RAM_OPCFG_NEXTOP_S) |
            (1 << hal.PBE_GENERIC_RAM_OPCFG_SINGLE_S) |
            (0 << hal.PBE_GENERIC_RAM_OPCFG_IFSPERIOD_S) |
            (0 << hal.PBE_GENERIC_RAM_OPCFG_RXREPEATOK_S) |
            (0 << hal.PBE_GENERIC_RAM_OPCFG_RFINTERVAL_S);
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_OPCFG).* = em.as(u16, cfg_val);
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_NESB).* = hal.PBE_GENERIC_RAM_NESB_NESBMODE_OFF;
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_MAXLEN).* = 32; // TODO
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_RXTIMEOUT).* = timeout * 4;
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_FIRSTRXTIMEOUT).* = timeout * 4;
        RfFreq.program(freqFromChan(chan));
        reg(hal.LRFDDBELL_BASE + hal.LRFDDBELL_O_IMASK0).* |= hal.LRF_EventOpDone | hal.LRF_EventOpError;
        hal.NVIC_EnableIRQ(hal.LRFD_IRQ0_IRQn);
        while (reg(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_MSGBOX).* == 0) {}
        reg(hal.SYSTIM_BASE + hal.SYSTIM_O_CH2CC).* = reg(hal.SYSTIM_BASE + hal.SYSTIM_O_TIME250N).*;
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_API).* = hal.PBE_GENERIC_REGDEF_API_OP_RX;
    }

    pub fn startCw(chan: u8, power: i8) void {
        setState(.CW);
        RfPower.program(power);
        RfCtrl.enableImages();
        const cfg_val: u32 =
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
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_OPCFG).* = em.as(u16, cfg_val);
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_NESB).* = (hal.PBE_GENERIC_RAM_NESB_NESBMODE_OFF);
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_PATTERN).* = 0;
        reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_MODCTRL).* |= hal.LRFDMDM_MODCTRL_TONEINSERT_M;
        RfFreq.program(freqFromChan(chan));
        reg(hal.LRFDDBELL_BASE + hal.LRFDDBELL_O_IMASK0).* |= hal.LRF_EventOpDone | hal.LRF_EventOpError;
        while (reg(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_MSGBOX).* == 0) {}
        reg(hal.SYSTIM_BASE + hal.SYSTIM_O_CH2CC).* = reg(hal.SYSTIM_BASE + hal.SYSTIM_O_TIME250N).*;
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_API).* = hal.PBE_GENERIC_REGDEF_API_OP_TX;
    }

    pub fn startRx(chan: u8, timeout: u16) void {
        setState(.RX);
        RfFifo.prepareRX();
        RfCtrl.enableImages();
        rx_timeout = false;
        switch (RadioConfig.phy) {
            .BLE_1M => {
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_MAXLEN).* = 37;
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_OPCFG).* = 0 << hal.PBE_BLE5_RAM_OPCFG_REPEAT_S;

                const whiten_init = chan | 0x40;
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_WHITEINIT).* = whiten_init;
                // reg(hal.LRFDPBE32_BASE + hal.LRFDPBE32_O_MDMSYNCA).* = 0x8E89_BED6 ^ (em.as(u32, whiten_init) << 24);

                // reg(hal.LRFDPBE32_BASE + hal.LRFDPBE32_O_MDMSYNCA).* = 0x7176_4129;
                var demc1be0 = reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_DEMC1BE0).*;
                var demc1be2 = reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_DEMC1BE2).*;
                demc1be0 |= hal.LRFDMDM_DEMC1BE0_MASKA_M | hal.LRFDMDM_DEMC1BE0_MASKB_M;
                demc1be2 = (demc1be2 & ~hal.LRFDMDM_DEMC1BE2_THRESHOLDC_M) | (0x7F << hal.LRFDMDM_DEMC1BE2_THRESHOLDC_S);
                reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_DEMC1BE0).* = demc1be0;
                reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_DEMC1BE2).* = demc1be2;
            },
            .PROP_1M, .PROP_250K => {
                const cfg_val: u32 =
                    (0 << hal.PBE_GENERIC_RAM_OPCFG_RXFILTEROP_S) |
                    (1 << hal.PBE_GENERIC_RAM_OPCFG_RXINCLUDEHDR_S) |
                    (1 << hal.PBE_GENERIC_RAM_OPCFG_RXREPEATNOK_S) |
                    (0 << hal.PBE_GENERIC_RAM_OPCFG_START_S) |
                    // (1 << hal.PBE_GENERIC_RAM_OPCFG_FS_NOCAL_S) |
                    // (1 << hal.PBE_GENERIC_RAM_OPCFG_FS_KEEPON_S) |
                    (1 << hal.PBE_GENERIC_RAM_OPCFG_NEXTOP_S) |
                    (1 << hal.PBE_GENERIC_RAM_OPCFG_SINGLE_S) |
                    (0 << hal.PBE_GENERIC_RAM_OPCFG_IFSPERIOD_S) |
                    (0 << hal.PBE_GENERIC_RAM_OPCFG_RXREPEATOK_S) |
                    (0 << hal.PBE_GENERIC_RAM_OPCFG_RFINTERVAL_S);
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_OPCFG).* = em.as(u16, cfg_val);
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_NESB).* = hal.PBE_GENERIC_RAM_NESB_NESBMODE_OFF;
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_MAXLEN).* = 256; // TODO
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_RXTIMEOUT).* = 0;
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_FIRSTRXTIMEOUT).* = 0;
            },
            .NONE => {},
        }
        var demc1be1 = reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_DEMC1BE1).*;
        demc1be1 = (demc1be1 & ~hal.LRFDMDM_DEMC1BE1_THRESHOLDB_M) | (0x7F << hal.LRFDMDM_DEMC1BE1_THRESHOLDB_S);
        reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_DEMC1BE1).* = demc1be1;
        RfFreq.program(freqFromChan(chan));
        reg(hal.LRFDDBELL_BASE + hal.LRFDDBELL_O_IMASK0).* |=
            hal.LRF_EventOpError | hal.LRF_EventRxNok | hal.LRF_EventRxOk | hal.LRF_EventSystim1;
        hal.NVIC_EnableIRQ(hal.LRFD_IRQ0_IRQn);
        while (reg(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_MSGBOX).* == 0) {}
        reg(hal.SYSTIM_BASE + hal.SYSTIM_O_CH2CC).* = reg(hal.SYSTIM_BASE + hal.SYSTIM_O_TIME250N).* + 1000;
        if (timeout > 0) {
            reg(hal.LRFDDBELL_BASE + hal.LRFDDBELL_O_ICLR0).* = hal.LRFDDBELL_ICLR0_SYSTIM1_M;
            reg(hal.SYSTIM_BASE + hal.SYSTIM_O_CH3CC).* = reg(hal.SYSTIM_BASE + hal.SYSTIM_O_TIME250N).* + em.as(u32, timeout) * 4000;
        }
        const op = switch (RadioConfig.phy) {
            .BLE_1M => hal.PBE_BLE5_REGDEF_API_OP_RXRAW,
            .PROP_1M, .PROP_250K => hal.PBE_GENERIC_REGDEF_API_OP_RX,
            .NONE => unreachable,
        };
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_API).* = op;
    }

    pub fn startTx(pkt: []const u8, chan: u8, power: i8) void {
        setState(.TX);
        // _ = pkt;
        RfFifo.writePkt(pkt);
        // reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCMD).* = (hal.LRFDPBE_FCMD_DATA_TXFIFO_RETRY >> hal.LRFDPBE_FCMD_DATA_S);
        RfPower.program(power);
        RfCtrl.enableImages();
        switch (RadioConfig.phy) {
            .BLE_1M => {
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_OPCFG).* = 0;
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_WHITEINIT).* = chan | 0x40;
            },
            .PROP_1M, .PROP_250K => {
                const cfg_val =
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
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_OPCFG).* = em.as(u16, cfg_val);
                em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_GENERIC_RAM_O_NESB).* = (hal.PBE_GENERIC_RAM_NESB_NESBMODE_OFF);
            },
            .NONE => {},
        }
        RfFreq.program(freqFromChan(chan));
        reg(hal.LRFDDBELL_BASE + hal.LRFDDBELL_O_IMASK0).* |= hal.LRF_EventOpDone | hal.LRF_EventOpError;
        hal.NVIC_EnableIRQ(hal.LRFD_IRQ0_IRQn);
        while (reg(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_MSGBOX).* == 0) {}
        reg(hal.SYSTIM_BASE + hal.SYSTIM_O_CH2CC).* = reg(hal.SYSTIM_BASE + hal.SYSTIM_O_TIME250N).*;
        const op = switch (RadioConfig.phy) {
            .BLE_1M => hal.PBE_BLE5_REGDEF_API_OP_TXRAW,
            .PROP_1M, .PROP_250K => hal.PBE_GENERIC_REGDEF_API_OP_TX,
            .NONE => unreachable,
        };
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_API).* = op;
    }

    pub fn waitReady() void {
        Idle.waitOnly(.SET);
        while (cur_state != .READY) {
            Idle.exec();
        }
        Idle.waitOnly(.CLR);
    }

    export fn LRFD_IRQ0_isr() void {
        if (em.IS_META) return;
        const mis = reg(hal.LRFDDBELL_BASE + hal.LRFDDBELL_O_MIS0).*;
        reg(hal.LRFDDBELL_BASE + hal.LRFDDBELL_O_ICLR0).* = mis;
        // em.@"%%[>]"(mis);
        // em.@"%%[a]"();
        if ((mis & hal.LRF_EventOpError) != 0) {
            em.@"%%[>]"(em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_ENDCAUSE).*);
            em.fail();
        }
        if ((mis & hal.LRF_EventSystim1) != 0) {
            rx_timeout = true;
        }
        // if ((mis & hal.LRF_EventRxOk) != 0) {
        //     em.print("peek {x}\n", .{RfFifo.peek(0)});
        // }
        hal.NVIC_ClearPendingIRQ(hal.LRFD_IRQ0_IRQn);
        setState(.READY);
    }

    // pub fn em__onexit() void {
    //     const ris = reg(hal.LRFDDBELL_BASE + hal.LRFDDBELL_O_RIS0).*;
    //     const mis = reg(hal.LRFDDBELL_BASE + hal.LRFDDBELL_O_MIS0).*;
    //     em.print("ris = {x}, mis = {x}\n", .{ ris, mis });
    // }
};


//->> zigem publish #|4587682a7cc69d1fe9f1f921835e4ba84689c4fdafc83a95c767d0ba3a718b80|#

//->> EM__META publics

//->> EM__TARG publics
pub const disable = EM__TARG.disable;
pub const enable = EM__TARG.enable;
pub const readPkt = EM__TARG.readPkt;
pub const readRssi = EM__TARG.readRssi;
pub const startCs = EM__TARG.startCs;
pub const startCw = EM__TARG.startCw;
pub const startRx = EM__TARG.startRx;
pub const startTx = EM__TARG.startTx;
pub const waitReady = EM__TARG.waitReady;

//->> zigem publish -- end of generated code
