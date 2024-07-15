pub const em = @import("../../.gen/em.zig");
pub const em__U = em.Module(@This(), .{});

pub const AppLed = em.Import.@"em__distro/BoardC".AppLed;
pub const Common = em.Import.@"em.mcu/Common";
pub const OneShot = em.Import.@"em__distro/BoardC".OneShot;

pub const EM__HOST = struct {
    //
};

pub const EM__TARG = struct {
    //
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

    fn handler(_: OneShot.Handler) void {
        em.@"%%[c]"();
        active_flag = false;
    }
};
