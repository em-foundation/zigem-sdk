pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    blinkF: em.Param(FiberMgr.Obj),
};

pub const AppLed = em.import2.@"em__distro/BoardC".AppLed;
pub const Common = em.import2.@"em.mcu/Common";
pub const FiberMgr = em.import2.@"em.utils/FiberMgr";

pub const EM__META = struct {
    //
    pub fn em__constructH() void {
        const blinkF = FiberMgr.createH(em__U.fxn("blinkFB", FiberMgr.BodyArg));
        em__C.blinkF.set(blinkF);
    }
};

pub const EM__TARG = struct {
    //
    const blinkF = em__C.blinkF.get();

    pub fn em__run() void {
        blinkF.post();
        FiberMgr.run();
    }

    var count: u8 = 5;

    pub fn blinkFB(_: FiberMgr.BodyArg) void {
        em.@"%%[d]"();
        count -= 1;
        if (count == 0) em.halt();
        AppLed.on();
        Common.BusyWait.wait(100_000);
        AppLed.off();
        Common.BusyWait.wait(100_000);
        blinkF.post();
    }
};
