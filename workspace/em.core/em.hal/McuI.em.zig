pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__SPEC = struct {
    startup: *const @TypeOf(EM__TARG.startup) = &EM__TARG.startup,
};

pub const EM__TARG = struct {
    pub fn startup() void {
        return;
    }
};
