pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const AlarmMgr = em.Import.@"em.utils/AlarmMgr";
pub const AppLed = em.Import.@"em__distro/BoardC".AppLed;
pub const FiberMgr = em.Import.@"em.utils/FiberMgr";

pub const c_alarm = em__unit.config("alarm", AlarmMgr.Obj);
pub const c_blinkF = em__unit.config("blinkF", FiberMgr.Obj);

pub const EM__HOST = struct {
    //
    pub fn em__constructH() void {
        c_blinkF.set(FiberMgr.createH(em__unit.func("blinkFB", em.CB(FiberMgr.FiberBody))));
        c_alarm.set(AlarmMgr.createH(c_blinkF.get()));
    }
};

pub const EM__TARG = struct {
    //
    const alarm = c_alarm.unwrap().O();
    const blinkF = c_blinkF.unwrap().O();
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
