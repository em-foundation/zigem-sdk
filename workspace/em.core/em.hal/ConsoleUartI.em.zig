pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__TARG = struct {
    flush: fn () void,
    put: fn (data: u8) void,
};


//->> zigem publish #|95cda101f1b8a5c317279b87c4b1e02894a61fb7ddde09d3822e95fef1a8ae71|#

pub fn flush () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn put (data: u8) void {
    // TODO
    _ = data;
    return em.std.mem.zeroes(void);
}

const em__Self = @This();

pub const EM__SPEC = struct {
    flush: *const @TypeOf(em__Self.flush) = &em__Self.flush,
    put: *const @TypeOf(em__Self.put) = &em__Self.put,
};

//->> zigem publish -- end of generated code
