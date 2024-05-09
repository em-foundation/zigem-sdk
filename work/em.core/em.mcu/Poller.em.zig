pub const EM__SPEC = null;

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const Common = em.Import.@"em.mcu/Common";

pub const x_OneShot = em__unit.proxy("BusyWait", em.Import.@"em.hal/OneShotMilliI");
pub const OneShot = x_OneShot.unwrap();

pub const PollFxn = *const fn () bool;

pub const EM__HOST = null;

pub const EM__TARG = null;

var active_flag: bool = false;

fn handler(_: OneShot.Handler_CB) void {
    active_flag = false;
}

pub fn pause(time_ms: u32) void {
    if (time_ms == 0) return;
    active_flag = true;
    OneShot.enable(time_ms, handler, null);
    while (active_flag) {
        Common.Idle.exec();
    }
}

pub fn poll(rate_ms: u32, count: usize, fxn: PollFxn) usize {
    _ = rate_ms;
    _ = count;
    _ = fxn;
    return 0;
}
