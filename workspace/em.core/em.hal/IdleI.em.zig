pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__SPEC = struct {
    exec: *const @TypeOf(EM__TARG.exec) = &EM__TARG.exec,
    wakeup: *const @TypeOf(EM__TARG.wakeup) = &EM__TARG.wakeup,
};

pub const EM__TARG = struct {
    pub fn exec() void {
        return;
    }
    pub fn wakeup() void {
        return;
    }
};
