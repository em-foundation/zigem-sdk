pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const AppLed = em.import2.@"em__distro/BoardC".AppLed;
pub const Common = em.import2.@"em.mcu/Common";
pub const OneShot = em.import2.@"em__distro/BoardC".OneShot;

// -------- TARG --------

var active_flag = false;

pub fn em__run() void {
    Common.GlobalInterrupts.enable();
    for (0..5) |_| {
        em.@"%%[d]"();
        AppLed.on();
        Common.BusyWait.wait(5000);
        AppLed.off();
        active_flag = true;
        OneShot.enable(100, &handler, null);
        while (active_flag) {
            Common.Idle.exec();
        }
    }
}

fn handler(_: OneShot.HandlerArg) void {
    em.@"%%[c]"();
    active_flag = false;
}
