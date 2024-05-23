pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const Common = em.Import.@"em.mcu/Common";
pub const WakeupTimer = em.Import.@"ti.mcu.cc23xx/WakeupRtc";

pub const EM__HOST = struct {
    //
};

pub const EM__TARG = struct {
    //
    pub fn em__run() void {
        Common.GlobalInterrupts.enable();
        const ticks = WakeupTimer.secs256ToTicks(384);
        const thresh = WakeupTimer.ticksToThresh(ticks);
        WakeupTimer.enable(thresh, &handler);
        em.@"%%[d+]"();
        Common.Idle.exec();
    }

    fn handler(_: WakeupTimer.Handler) void {
        em.@"%%[d-]"();
    }
};
