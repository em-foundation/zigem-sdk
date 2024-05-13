pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const AppLed = em.Import.@"em__distro/BoardC".AppLed;
pub const Common = em.Import.@"em.mcu/Common";

pub const EM__HOST = struct {};

pub const EM__TARG = struct {};

pub fn em__run() void {
    AppLed.on();
    for (0..10) |_| {
        Common.BusyWait.wait(500_000);
        AppLed.toggle();
    }
    AppLed.off();
}
