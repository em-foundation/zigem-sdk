pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    OneShot: em.Proxy(OneShotI),
};

pub const Common = em.import.@"em.mcu/Common";
pub const OneShotI = em.import.@"em.hal/OneShotI";

pub const PollFxn = *const fn () bool;

pub const EM__META = struct {
    //
    pub const x_OneShot = em__C.OneShot;
};

pub const EM__TARG = struct {
    //
    const OneShot = em__C.OneShot.unwrap();

    var active_flag: bool = false;
    const active_flag_VP: *volatile bool = &active_flag;

    fn handler(_: OneShotI.HandlerArg) void {
        active_flag_VP.* = false;
    }

    pub fn pause(time_ms: u32) void {
        EM__TARG.upause(time_ms * 1000);
    }

    pub fn poll(rate_ms: u32, count: usize, fxn: PollFxn) usize {
        _ = rate_ms;
        _ = count;
        _ = fxn;
        return 0;
    }

    pub fn upause(time_us: u32) void {
        if (time_us == 0) return;
        active_flag_VP.* = true;
        OneShot.uenable(time_us, handler, null);
        while (active_flag_VP.*) {
            Common.Idle.exec();
        }
    }
};


//->> zigem publish #|1b3499e06cad7b1f78367d80ec4420e9d3b5c5cd018ed68c17e2716a4481042a|#

//->> EM__META publics
pub const x_OneShot = EM__META.x_OneShot;

//->> EM__TARG publics
pub const pause = EM__TARG.pause;
pub const poll = EM__TARG.poll;
pub const upause = EM__TARG.upause;

//->> zigem publish -- end of generated code
