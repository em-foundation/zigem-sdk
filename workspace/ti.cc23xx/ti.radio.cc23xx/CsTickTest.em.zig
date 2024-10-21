pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    txTicker: em.Param(TickerMgr.Obj),
};

pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const Common = em.import.@"em.mcu/Common";
pub const FiberMgr = em.import.@"em.utils/FiberMgr";
pub const Poller = em.import.@"em.mcu/Poller";
pub const TickerMgr = em.import.@"em.utils/TickerMgr";
pub const RadioConfig = em.import.@"ti.radio.cc23xx/RadioConfig";
pub const RadioDriver = em.import.@"ti.radio.cc23xx/RadioDriver";

pub const EM__META = struct {
    pub fn em__configureM() void {
        RadioConfig.c_phy.setM(.PROP_250K);
    }
    pub fn em__constructM() void {
        em__C.txTicker.setM(TickerMgr.createM());
    }
};

pub const EM__TARG = struct {
    //
    const txTicker = em__C.txTicker.unwrap();

    pub fn em__run() void {
        txTicker.start(256, &tickCb);
        FiberMgr.run();
    }

    fn tickCb(_: TickerMgr.CallbackArg) void {
        RadioDriver.enable();
        RadioDriver.startCs(17, 0);
        Poller.upause(125);
        const rssi = RadioDriver.readRssi();
        if (rssi > -35) AppLed.wink(5);
        RadioDriver.disable();
    }
};


//->> zigem publish #|a98bdd23a033fea6e7b87f6dbbbd1a61f2954011fbbe31f398d064de6baac9b7|#

//->> EM__META publics

//->> EM__TARG publics

//->> zigem publish -- end of generated code
