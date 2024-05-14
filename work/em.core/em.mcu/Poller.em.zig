pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const Common = em.Import.@"em.mcu/Common";

pub const x_OneShot = em__unit.proxy("OneShot", em.Import.@"em.hal/OneShotMilliI");

pub const PollFxn = *const fn () bool;

pub const EM__HOST = struct {
    //
};

pub const EM__TARG = struct {
    //
    const OneShot = x_OneShot.unwrap();

    var active_flag: bool = false;
    const vptr: *volatile bool = &active_flag;

    fn handler(_: OneShot.Handler_CB) void {
        vptr.* = false;
    }

    pub fn pause(time_ms: u32) void {
        if (time_ms == 0) return;
        active_flag = true;
        OneShot.enable(time_ms, handler, null);
        while (vptr.*) {
            em.@"%%[d+]"();
            Common.Idle.exec();
            em.@"%%[d-]"();
        }
    }

    pub fn poll(rate_ms: u32, count: usize, fxn: PollFxn) usize {
        _ = rate_ms;
        _ = count;
        _ = fxn;
        return 0;
    }
};
