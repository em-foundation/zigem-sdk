pub const em = @import("../../.gen/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    em__upath: []const u8,
    blinkF: em.Param(FiberMgr.Obj),
};

pub const AppButEdge = em.import.@"em__distro/BoardC".AppButEdge;
pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const Common = em.import.@"em.mcu/Common";
pub const FiberMgr = em.import.@"em.utils/FiberMgr";

pub const EM__HOST = struct {
    pub fn em__constructH() void {
        AppButEdge.setDetectHandlerH(em__U.fxn("handler", AppButEdge.Handler));
        const blinkF = FiberMgr.createH(em__U.fxn("blinkFB", FiberMgr.FiberBody));
        em__C.blinkF.set(blinkF);
    }
};

pub const EM__TARG = struct {
    //
    const blinkF = em__C.blinkF;

    pub fn em__startup() void {
        AppButEdge.makeInput();
        AppButEdge.setInternalPullup(true);
        AppButEdge.setDetectFallingEdge();
    }

    pub fn em__run() void {
        AppButEdge.enableDetect();
        FiberMgr.run();
    }

    pub fn blinkFB(_: FiberMgr.FiberBody) void {
        em.@"%%[d]"();
        AppLed.on();
        Common.BusyWait.wait(5000);
        AppLed.off();
        AppButEdge.enableDetect();
    }

    pub fn handler(_: AppButEdge.Handler) void {
        em.@"%%[c]"();
        AppButEdge.clearDetect();
        blinkF.post();
    }
};

//module Button2P
//
//private:
//
//    function blinkFB: FiberMgr.FiberBodyFxn
//    function handler: AppButEdge.Handler
//
//    config blinkF: FiberMgr.Fiber&
//
//end
//
//def em$construct()
//    AppButEdge.setDetectHandlerH(handler)
//    blinkF = FiberMgr.createH(blinkFB)
//end
//
//def em$startup()
//    AppButEdge.makeInput()
//    AppButEdge.setInternalPullup(true)
//    AppButEdge.setDetectFallingEdge()
//end
//
//def em$run()
//    AppButEdge.enableDetect()
//    FiberMgr.run()
//end
//
//def blinkFB(arg)
//    %%[d]
//    AppLed.on()
//    Common.BusyWait.wait(5000)
//    AppLed.off()
//    AppButEdge.enableDetect()
//end
//
//def handler()
//    %%[c]
//    AppButEdge.clearDetect()
//    blinkF.post()
//end
//
//
//
//
