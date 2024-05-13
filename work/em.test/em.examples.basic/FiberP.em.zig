pub const EM__SPEC = null;

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const AppLed = em.Import.@"em__distro/BoardC".AppLed;
pub const Common = em.Import.@"em.mcu/Common";
pub const FiberMgr = em.Import.@"em.utils/FiberMgr";

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

pub fn em__run() void {
    if (em.hosted) return;
    blinkF.post();
    FiberMgr.run();
}

var count: u8 = 5;

pub fn blinkFB(_: FiberMgr.FiberBody_CB) void {
    if (em.hosted) return;
    em.@"%%[d]"();
    count -= 1;
    if (count == 0) em.halt();
    AppLed.on();
    Common.BusyWait.wait(100_000);
    AppLed.off();
    Common.BusyWait.wait(100_000);
    blinkF.post();
}
