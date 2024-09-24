pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__SPEC = struct {
    disable: *const @TypeOf(EM__TARG.disable) = &EM__TARG.disable,
    enable: *const @TypeOf(EM__TARG.enable) = &EM__TARG.enable,
    isEnabled: *const @TypeOf(EM__TARG.isEnabled) = &EM__TARG.isEnabled,
    restore: *const @TypeOf(EM__TARG.restore) = &EM__TARG.restore,
};

pub const EM__TARG = struct {
    pub fn disable() u32 {
        return 0;
    }
    pub fn enable() void {
        return;
    }
    pub fn isEnabled() bool {
        return false;
    }
    pub fn restore(key: u32) void {
        _ = key;
        return;
    }
};
