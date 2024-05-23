pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const Common = em.Import.@"em.mcu/Common";
pub const Uptimer = em.Import.@"ti.mcu.cc23xx/UptimerRtc";

pub const EM__HOST = struct {
    //
};

pub const EM__TARG = struct {
    //
    pub fn em__run() void {
        report();
        em.@"%%[d+]"();
        Common.BusyWait.wait(3_000_000);
        em.@"%%[d-]"();
        report();
    }

    pub fn report() void {
        const time = Uptimer.read();
        em.@"%%[>]"(time.secs);
        em.@"%%[>]"(time.subs);
    }
};
