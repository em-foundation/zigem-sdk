pub const em = @import("../../.gen/em.zig");
pub const em__U = em.Module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const Common = em.import.@"em.mcu/Common";
pub const FiberMgr = em.import.@"em.utils/FiberMgr";
pub const OneShot = em.import.@"em__distro/BoardC".OneShot;

pub const EM__CONFIG = struct {
    blinkF: em.Param(FiberMgr.Obj),
};

pub const EM__HOST = struct {
    //
    pub fn em__constructH() void {
        em__C.blinkF.set(FiberMgr.createH(em__U.func("blinkFB", em.CB(FiberMgr.FiberBody))));
    }
};

pub const EM__TARG = struct {
    //
    const blinkF = em__C.blinkF.unwrap();
    var count: u8 = 5;

    pub fn em__run() void {
        blinkF.post();
        FiberMgr.run();
    }

    pub fn blinkFB(_: FiberMgr.FiberBody) void {
        em.@"%%[d]"();
        count -= 1;
        if (count == 0) em.halt();
        AppLed.on();
        Common.BusyWait.wait(5000);
        AppLed.off();
        OneShot.enable(100, &handler, null);
    }

    fn handler(_: OneShot.Handler) void {
        em.@"%%[c]"();
        blinkF.post();
    }
};
