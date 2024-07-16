pub const em = @import("../../.gen/em.zig");
pub const em__U = em.module(@This(), .{
    .inherits = em.import.@"em.hal/UptimerI",
});

pub const Rtc = em.import.@"ti.mcu.cc23xx/Rtc";

pub const Time = em__U.inherits.Time;

pub const EM__HOST = struct {
    //
};

pub const EM__TARG = struct {
    //
    var cur_time = Time{};

    pub fn calibrate(secs256: u32, ticks: u32) u16 {
        // TODO
        _ = secs256;
        _ = ticks;
        return 0;
    }

    pub fn read() *const Time {
        cur_time.secs = Rtc.getRaw(&cur_time.subs);
        return &cur_time;
    }

    pub fn resetSync() void {
        // TODO
        return;
    }

    pub fn trim() u16 {
        // TODO
        return 0;
    }
};
