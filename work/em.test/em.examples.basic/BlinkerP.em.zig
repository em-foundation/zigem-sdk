pub const EM__SPEC = {};

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const BoardC = em.Import.@"em__distro/BoardC";
pub const Common = em.Import.@"em.mcu/Common";

pub const EM__HOST = {};

pub const EM__TARG = {};

const AppLed = BoardC.AppLed;

pub fn em__run() void {
    AppLed.on();
    for (0..10) |_| {
        Common.BusyWait.wait(500_000);
        AppLed.toggle();
    }
    AppLed.off();
}
