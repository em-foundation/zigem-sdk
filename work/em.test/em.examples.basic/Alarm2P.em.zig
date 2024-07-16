pub const em = @import("../../.gen/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const AlarmMgr = em.import.@"em.utils/AlarmMgr";
pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const FiberMgr = em.import.@"em.utils/FiberMgr";

pub const EM__CONFIG = struct {
    alarm: em.Param(AlarmMgr.Obj),
    blinkF: em.Param(FiberMgr.Obj),
};

pub const EM__HOST = struct {
    //
    pub fn em__constructH() void {
        const blinkF = FiberMgr.createH(em__U.func("blinkFB", em.CB(FiberMgr.FiberBody)));
        const alarm = AlarmMgr.createH(blinkF);
        em__C.alarm.set(alarm);
        em__C.blinkF.set(blinkF);
    }
};

pub const EM__TARG = struct {
    //
    const alarm = em__C.alarm.unwrap();
    const blinkF = em__C.blinkF.unwrap();
    var counter: u32 = 0;

    pub fn em__run() void {
        blinkF.post();
        FiberMgr.run();
    }

    pub fn blinkFB(_: FiberMgr.FiberBody) void {
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
