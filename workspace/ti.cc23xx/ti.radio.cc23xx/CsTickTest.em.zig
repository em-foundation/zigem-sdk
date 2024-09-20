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
    pub fn em__configureH() void {
        RadioConfig.phy.set(.PROP_250K);
    }
    pub fn em__constructH() void {
        em__C.txTicker.set(TickerMgr.createH());
    }
};

pub const EM__TARG = struct {
    //
    const txTicker = em__C.txTicker;

    pub fn em__run() void {
        txTicker.start(256, &tickCb);
        FiberMgr.run();
    }

    fn tickCb(_: TickerMgr.CallbackArg) void {
        RadioDriver.enable();
        RadioDriver.startRx(17, 0);
        Poller.upause(125);
        //RadioDriver.waitReady();
        const rssi = RadioDriver.readRssi();
        if (rssi > -35) AppLed.wink(5);
        //em.print("rssi = {d}\n", .{RadioDriver.readRssi()});
        RadioDriver.disable();
    }
};
