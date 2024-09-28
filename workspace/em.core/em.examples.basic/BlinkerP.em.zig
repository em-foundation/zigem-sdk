pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const AppLed = em.import2.@"em__distro/BoardC".AppLed;
pub const Common = em.import2.@"em.mcu/Common";

pub fn em__run() void {
    AppLed.on();
    for (0..10) |_| {
        Common.BusyWait.wait(500_000);
        AppLed.toggle();
    }
    AppLed.off();
}
