pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    alarm: em.Param2(AlarmMgr.Obj),
    blinkF: em.Param2(FiberMgr.Obj),
};

pub const AlarmMgr = em.import.@"em.utils/AlarmMgr";
pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const FiberMgr = em.import.@"em.utils/FiberMgr";

pub const EM__META = struct {
    //
    pub fn em__constructH() void {
        const blinkF = FiberMgr.createH(em__U.fxn("blinkFB", FiberMgr.BodyArg));
        const alarm = AlarmMgr.createH(blinkF);
        em__C.alarm.set(alarm);
        em__C.blinkF.set(blinkF);
    }
};

pub const EM__TARG = struct {
    //
    const alarm = em__C.alarm.get();
    const blinkF = em__C.blinkF.get();
    var counter: u32 = 0;

    pub fn em__run() void {
        blinkF.post();
        FiberMgr.run();
    }

    pub fn blinkFB(_: FiberMgr.BodyArg) void {
        em.@"%%[c]"();
        counter += 1;
        if ((counter & 0x1) != 0) {
            AppLed.wink(100); // 100ms
        } else {
            AppLed.wink(5); // 5ms
        }
        alarm.wakeupAt(384); // 1.5s window
    }
};
