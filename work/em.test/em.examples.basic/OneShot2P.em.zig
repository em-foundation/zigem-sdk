pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const AppLed = em.Import.@"em__distro/BoardC".AppLed;
pub const Common = em.Import.@"em.mcu/Common";
pub const FiberMgr = em.Import.@"em.utils/FiberMgr";
pub const OneShot = em.Import.@"em__distro/BoardC".OneShot;

pub const c_blinkF = em__unit.config("blinkF", FiberMgr.Ref);

pub const EM__HOST = struct {
    //
    pub fn em__constructH() void {
        c_blinkF.set(FiberMgr.createH(em__unit.func("blinkFB", FiberMgr.FiberBody)));
    }
};

pub const EM__TARG = struct {
    //
    const blinkF = FiberMgr.get(c_blinkF.unwrap()).?;
    var count: u8 = 5;

    pub fn em__run() void {
        blinkF.post();
        FiberMgr.run();
    }

    pub fn blinkFB(_: FiberMgr.FiberBody_CB) void {
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
