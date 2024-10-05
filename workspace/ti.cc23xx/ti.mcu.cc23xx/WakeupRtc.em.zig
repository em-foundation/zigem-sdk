pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{
    .inherits = WakeupTimerI,
});

pub const Rtc = em.import.@"ti.mcu.cc23xx/Rtc";
pub const WakeupTimerI = em.import.@"em.hal/WakeupTimerI";

pub const HandlerFxn = WakeupTimerI.HandlerFxn;
pub const HandlerArg = WakeupTimerI.HandlerArg;

pub const disable = EM__TARG.disable;
pub const enable = EM__TARG.enable;
pub const secsAligned = EM__TARG.secsAligned;
pub const secsToThresh = EM__TARG.secsToThresh;

const Seconds_24p8 = WakeupTimerI.Seconds_24p8;
const Thresh = WakeupTimerI.Thresh;

pub const EM__TARG = struct {
    //
    fn disable() void {
        Rtc.disable();
    }

    fn enable(secs256: u32, handler: HandlerFxn) void {
        if (em.IS_META) return;
        Rtc.enable(secs256, @ptrCast(handler));
    }

    pub fn secsAligned(secs: Seconds_24p8) Seconds_24p8 {
        const raw_time = Rtc.getRawTime();
        const raw_secs = em.@"<>"(Seconds_24p8, raw_time.secs << 8 | raw_time.subs >> 24);
        const rem = raw_secs % secs;
        return secs - rem;
    }

    pub fn secsToThresh(secs: Seconds_24p8) Thresh {
        return Rtc.toThresh(secs << 8);
    }
};
