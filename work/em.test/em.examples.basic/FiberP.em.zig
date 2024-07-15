pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});
pub const em__C = em__unit.Config(EM__CONFIG);

pub const AppLed = em.Import.@"em__distro/BoardC".AppLed;
pub const Common = em.Import.@"em.mcu/Common";
pub const FiberMgr = em.Import.@"em.utils/FiberMgr";

pub const EM__CONFIG = struct {
    blinkF: em.Obj(FiberMgr.Fiber),
};

pub const EM__HOST = struct {
    //
    pub fn em__constructH() void {
        const blinkF = FiberMgr.createH(em__unit.func("blinkFB", em.CB(FiberMgr.FiberBody)));
        em.print("{any}", .{blinkF});
        em__C.blinkF = blinkF;
    }
};

pub const EM__TARG = struct {
    //
    const blinkF = em__C.blinkF;

    pub fn em__run() void {
        blinkF.post();
        FiberMgr.run();
    }

    var count: u8 = 5;

    pub fn blinkFB(_: FiberMgr.FiberBody) void {
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
