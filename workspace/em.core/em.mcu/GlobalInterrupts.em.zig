pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{ .inherits = GlobalInterruptsI });
pub const em__C = em__U.config(EM__CONFIG);

pub const GlobalInterruptsI = em.import.@"em.hal/GlobalInterruptsI";

pub const EM__CONFIG = struct {
    Impl: em.Proxy2(GlobalInterruptsI),
};

pub const EM__META = struct {
    pub const ImplX = em__C.Impl;
};

pub const EM__TARG = struct {
    const Impl = em__C.Impl.get();
    pub fn disable() u32 {
        return Impl.disable();
    }
    pub fn enable() void {
        return Impl.enable();
    }
    pub fn isEnabled() bool {
        return Impl.isEnabled();
    }
    pub fn restore(key: u32) void {
        return Impl.restore(key);
    }
};
