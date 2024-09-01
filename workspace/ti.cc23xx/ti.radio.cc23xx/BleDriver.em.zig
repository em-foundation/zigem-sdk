pub const em = @import("../../zigem/gen/em.zig");
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

pub const State = enum { IDLE, SETUP, READY, RX, TX };

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

    var cur_state: State = .IDLE;

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
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_FIFOCMDADD).* = em.@"<>"(u16, ((hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCMD) & 0x0FFF) >> 2);
        RfTrim.apply();
        // BLE-specific
        reg(hal.LRFDPBE32_BASE + hal.LRFDPBE32_O_MDMSYNCA).* = 0x8E89BED6;
        reg(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_CRCINITL).* = (0x555555 << 8);
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_EXTRABYTES).* = 6; // stat + rssi + timestamp
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_OWNADRL).* = 0xAAAA;
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_OWNADRM).* = 0xBBBB;
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_OWNADRH).* = 0xCCCC;
        // BLE-specific
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_ADVCFG).* = 0;
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_FILTPOLICY).* = 0;
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_RPACONNECT).* = 0;
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_RPACONNECT).* = 0;
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_FL1MASK).* = 0;
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_FL2MASK).* = 0;
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_OPCFG).* = 0;
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

    pub fn putWords(wbuf: []const u32) void {
        RfFifo.prepare();
        RfFifo.write(wbuf);
    }

    fn setState(s: State) void {
        // em.@"%%[a:]"(@intFromEnum(s));
        cur_state = s;
    }

    pub fn startTx(chan: u8, power: i8) void {
        setState(.TX);
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCMD).* = (hal.LRFDPBE_FCMD_DATA_TXFIFO_RETRY >> hal.LRFDPBE_FCMD_DATA_S);
        RfPower.program(power);
        RfCtrl.enableImages();
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_OPCFG).* = 0;
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_BLE5_RAM_O_WHITEINIT).* = chan | 0x40;
        RfFreq.program(freqFromChan(chan));
        reg(hal.LRFDDBELL_BASE + hal.LRFDDBELL_O_IMASK0).* |= 0x00008001; // done | error
        hal.NVIC_EnableIRQ(hal.LRFD_IRQ0_IRQn);
        while (reg(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_MSGBOX).* == 0) {}
        reg(hal.SYSTIM_BASE + hal.SYSTIM_O_CH2CC).* = reg(hal.SYSTIM_BASE + hal.SYSTIM_O_TIME250N).*;
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_API).* = hal.PBE_BLE5_REGDEF_API_OP_ADV;
    }

    pub fn waitReady() void {
        Idle.waitOnly(.SET);
        while (cur_state != .READY) {
            Idle.exec();
        }
        Idle.waitOnly(.CLR);
    }

    export fn LRFD_IRQ0_isr() void {
        if (em.hosted) return;
        const mis = reg(hal.LRFDDBELL_BASE + hal.LRFDDBELL_O_MIS0).*;
        reg(hal.LRFDDBELL_BASE + hal.LRFDDBELL_O_ICLR0).* = mis;
        if ((mis & 0x8000) != 0) {
            em.@"%%[>]"(em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_ENDCAUSE).*);
            em.fail();
        }
        hal.NVIC_ClearPendingIRQ(hal.LRFD_IRQ0_IRQn);
        setState(.READY);
    }
};
