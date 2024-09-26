pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__SPEC = struct {
    start: *const @TypeOf(EM__TARG.start) = &EM__TARG.start,
    stop: *const @TypeOf(EM__TARG.stop) = &EM__TARG.stop,
};

pub const EM__TARG = struct {
    pub fn start() void {
        return;
    }
    pub fn stop() u32 {
        return 0;
    }
};
