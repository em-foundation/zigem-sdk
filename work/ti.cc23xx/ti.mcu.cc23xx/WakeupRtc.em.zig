pub const em = @import("../../.gen/em.zig");
pub const em__U = em.module(@This(), .{
    .inherits = em.import.@"em.hal/WakeupTimerI",
});

pub const Rtc = em.import.@"ti.mcu.cc23xx/Rtc";

pub const Handler = em__U.inherits.Handler;

pub const EM__HOST = struct {
    //
};

pub const EM__TARG = struct {
    //
    pub fn disable() void {
        Rtc.disable();
    }

    pub fn enable(secs256: u32, handler: em.CB(Handler)) void {
        Rtc.enable(secs256, @ptrCast(handler));
    }

    pub fn secs256ToTicks(secs256: u32) u32 {
        return secs256 << 8;
    }

    pub fn ticksToThresh(ticks: u32) u32 {
        return Rtc.toThresh(ticks);
    }

    pub fn timeToTicks(secs: u32, subs: u32) u32 {
        return (secs << 16) | (subs >> 16);
    }
};
