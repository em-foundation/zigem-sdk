pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const AppLed = em.Import.@"em__distro/BoardC".AppLed;
pub const FiberMgr = em.Import.@"em.utils/FiberMgr";
pub const TickerMgr = em.Import.@"em.utils/TickerMgr";
pub const SysLed = em.Import.@"em__distro/BoardC".SysLed;

pub const c_appTicker = em__unit.config("appTicker", TickerMgr.Obj);
pub const c_sysTicker = em__unit.config("sysTicker", TickerMgr.Obj);

pub const EM__HOST = struct {
    pub fn em__constructH() void {
        c_appTicker.set(TickerMgr.createH());
        c_sysTicker.set(TickerMgr.createH());
    }
};

pub const EM__TARG = struct {
    //
    const appTicker = c_appTicker.unwrap().O();
    const sysTicker = c_sysTicker.unwrap().O();

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
