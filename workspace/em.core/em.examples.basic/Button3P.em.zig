pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    em__upath: []const u8,
};

pub const AppBut = em.import2.@"em__distro/BoardC".AppBut;
pub const AppLed = em.import2.@"em__distro/BoardC".AppLed;
pub const Common = em.import2.@"em.mcu/Common";
pub const FiberMgr = em.import2.@"em.utils/FiberMgr";
pub const SysLed = em.import2.@"em__distro/BoardC".SysLed;

// -------- TARG --------

pub fn em__run() void {
    AppBut.onPressed(onPressedCb, .{});
    FiberMgr.run();
}

pub fn onPressedCb(_: AppBut.OnPressedCbArg) void {
    em.@"%%[c]"();
    if (AppBut.isPressed()) {
        SysLed.on();
        Common.BusyWait.wait(40_000);
        SysLed.off();
    } else {
        AppLed.on();
        Common.BusyWait.wait(5_000);
        AppLed.off();
    }
}
