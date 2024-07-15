pub const em = @import("../../.gen/em.zig");
pub const em__U = em.Module(@This(), .{});

pub const AppLed = em.Import.@"em__distro/BoardC".AppLed;
pub const Common = em.Import.@"em.mcu/Common";
pub const Poller = em.Import.@"em.mcu/Poller";

pub const EM__HOST = struct {
    //
};

pub const EM__TARG = struct {
    //
    pub fn em__run() void {
        Common.GlobalInterrupts.enable();
        for (0..5) |_| {
            Poller.pause(100); // 100ms
            AppLed.wink(5); // 5ms
        }
    }
};
