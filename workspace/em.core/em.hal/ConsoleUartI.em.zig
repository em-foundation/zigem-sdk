pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__SPEC = struct {
    flush: *const @TypeOf(EM__TARG.flush) = &EM__TARG.flush,
    put: *const @TypeOf(EM__TARG.put) = &EM__TARG.put,
};

pub const EM__TARG = struct {
    pub fn flush() void {
        return;
    }
    pub fn put(data: u8) void {
        _ = data;
        return;
    }
};
