pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const AppLed = em.Import.@"em__distro/BoardC".AppLed;
pub const Common = em.Import.@"em.mcu/Common";
pub const FiberMgr = em.Import.@"em.utils/FiberMgr";
pub const OneShot = em.Import.@"em__distro/BoardC".OneShot;

pub const c_blinkF = em__unit.config("blinkF", em.Ref(FiberMgr.Fiber));

pub const EM__HOST = struct {};

pub fn em__constructH() void {
    c_blinkF.set(FiberMgr.createH(em__unit.func("blinkFB", @as(FiberMgr.FiberBody, blinkFB))));
}

pub const EM__TARG = struct {};

const blinkF = if (em.hosted)
    null
else
    c_blinkF.unwrap().obj;

var count: u8 = 5;

pub fn em__run() void {
    if (em.hosted) return;
    blinkF.post();
    FiberMgr.run();
}

pub fn blinkFB(_: FiberMgr.FiberBody_CB) void {
    if (em.hosted) return;
    em.@"%%[d]"();
    count -= 1;
    if (count == 0) em.halt();
    AppLed.on();
    Common.BusyWait.wait(5000);
    AppLed.off();
    OneShot.enable(100, &handler, null);
}

fn handler(_: OneShot.Handler_CB) void {
    em.@"%%[c]"();
    blinkF.post();
}

//package em.examples.basic
//
//from em$distro import BoardC
//from BoardC import AppLed
//
//from em$distro import McuC
//from McuC import OneShotMilli
//
//from em.mcu import Common
//from em.utils import FiberMgr
//
//module OneShot2P
//
//private:
//
//    function blinkFB: FiberMgr.FiberBodyFxn
//    function handler: OneShotMilli.Handler
//
//    config blinkF: FiberMgr.Fiber&
//    var count: uint8 = 5
//
//end
//
//def em$construct()
//    blinkF = FiberMgr.createH(blinkFB)
//end
//
//def em$run()
//    blinkF.post()
//    FiberMgr.run()
//end
//
//def blinkFB(arg)
//    %%[d]
//    AppLed.on()
//    Common.BusyWait.wait(5000)
//    AppLed.off()
//    halt if --count == 0
//    OneShotMilli.enable(100, handler, null)
//end
//
//def handler(arg)
//    %%[c]
//    blinkF.post()
//end
//
//
