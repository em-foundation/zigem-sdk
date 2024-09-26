pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__SPEC = struct {
    wait: *const @TypeOf(EM__TARG.wait) = &EM__TARG.wait,
};

pub const EM__TARG = struct {
    pub fn wait(usecs: u32) void {
        _ = usecs;
    }
};
