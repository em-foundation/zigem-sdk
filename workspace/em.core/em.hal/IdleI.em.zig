pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__TARG = struct {
    pub fn exec() void {
        return;
    }
    pub fn wakeup() void {
        return;
    }
};
