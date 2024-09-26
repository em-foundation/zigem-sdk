pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__SPEC = struct {
    off: *const @TypeOf(EM__TARG.off) = &EM__TARG.off,
    on: *const @TypeOf(EM__TARG.on) = &EM__TARG.on,
    toggle: *const @TypeOf(EM__TARG.toggle) = &EM__TARG.toggle,
};

pub const EM__TARG = struct {
    pub fn off() void {
        return;
    }
    pub fn on() void {
        return;
    }
    pub fn toggle() void {
        return;
    }
};
