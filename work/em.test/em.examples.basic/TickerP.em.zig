pub const em = @import("../../.gen/em.zig");
pub const em__U = em.Module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const FiberMgr = em.import.@"em.utils/FiberMgr";
pub const TickerMgr = em.import.@"em.utils/TickerMgr";
pub const SysLed = em.import.@"em__distro/BoardC".SysLed;

pub const EM__CONFIG = struct {
    appTicker: em.Param(TickerMgr.Obj),
    sysTicker: em.Param(TickerMgr.Obj),
};

pub const EM__HOST = struct {
    pub fn em__constructH() void {
        em__C.appTicker.set(TickerMgr.createH());
        em__C.sysTicker.set(TickerMgr.createH());
    }
};

pub const EM__TARG = struct {
    //
    const appTicker = em__C.appTicker.unwrap();
    const sysTicker = em__C.sysTicker.unwrap();

    pub fn em__run() void {
        appTicker.start(256, &appTickCb);
        sysTicker.start(384, &sysTickCb);
        FiberMgr.run();
    }

    fn appTickCb(_: TickerMgr.Callback) void {
        em.@"%%[c]"();
        AppLed.wink(100);
    }

    fn sysTickCb(_: TickerMgr.Callback) void {
        em.@"%%[d]"();
        SysLed.wink(100);
    }
};

//package em.examples.basic
//
//from em$distro import BoardC
//from BoardC import AppLed
//from BoardC import SysLed
//
//from em.utils import FiberMgr
//from em.utils import TickerMgr
//
//module TickerP
//
//private:
//
//    function appTickCb: TickerMgr.TickCallback
//    function sysTickCb: TickerMgr.TickCallback
//
//    config appTicker: TickerMgr.Ticker&
//    config sysTicker: TickerMgr.Ticker&
//
//end
//
//def em$construct()
//    appTicker = TickerMgr.createH()
//    sysTicker = TickerMgr.createH()
//end
//
//def em$run()
//    appTicker.start(256, appTickCb)
//    sysTicker.start(384, sysTickCb)
//    FiberMgr.run()
//end
//
//def appTickCb()
//    %%[c]
//    AppLed.wink(100)
//end
//
//def sysTickCb()
//    %%[d]
//    SysLed.wink(100)
//end
//
//
