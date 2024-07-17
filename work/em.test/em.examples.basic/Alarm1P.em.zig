pub const em = @import("../../.gen/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    alarm: em.Param(AlarmMgr.Obj),
    blinkF: em.Param(FiberMgr.Obj),
};

pub const AlarmMgr = em.import.@"em.utils/AlarmMgr";
pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const FiberMgr = em.import.@"em.utils/FiberMgr";

pub const EM__HOST = struct {
    //
    pub fn em__constructH() void {
        const blinkF = FiberMgr.createH(em__U.func("blinkFB", FiberMgr.FiberBody));
        const alarm = AlarmMgr.createH(blinkF);
        em__C.alarm.set(alarm);
        em__C.blinkF.set(blinkF);
    }
};

pub const EM__TARG = struct {
    //
    const alarm = em__C.alarm;
    const blinkF = em__C.blinkF;
    var counter: u32 = 0;

    pub fn em__run() void {
        blinkF.post();
        FiberMgr.run();
    }

    pub fn blinkFB(_: FiberMgr.FiberBody) void {
        em.@"%%[c]"();
        AppLed.wink(100); // 100 ms
        counter += 1;
        if ((counter & 0x1) != 0) {
            alarm.wakeup(512); // 2s
        } else {
            alarm.wakeup(192); // 750ms
        }
    }
};
