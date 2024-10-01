pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{
    .inherits = UptimerI,
});

pub const Rtc = em.import.@"ti.mcu.cc23xx/Rtc";
pub const UptimerI = em.import.@"em.hal/UptimerI";

pub const calibrate = EM__TARG.calibrate;
pub const read = EM__TARG.read;
pub const resetSync = EM__TARG.resetSync;
pub const trim = EM__TARG.trim;

pub const EM__TARG = struct {
    //
    const Time = UptimerI.Time;

    var cur_time = Time{};

    fn calibrate(secs256: u32, ticks: u32) u16 {
        // TODO
        _ = secs256;
        _ = ticks;
        return 0;
    }

    fn read() *const Time {
        cur_time.secs = Rtc.getRaw(&cur_time.subs);
        return &cur_time;
    }

    fn resetSync() void {
        // TODO
        return;
    }

    fn trim() u16 {
        // TODO
        return 0;
    }
};
