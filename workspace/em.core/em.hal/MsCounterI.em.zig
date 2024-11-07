pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__TARG = struct {
    start: fn () void,
    stop: fn () u32,
};


//->> zigem publish #|d6343c89276ff399a77b8575e624499e165b0197ca8c29031431dcad83736d3e|#

pub fn start () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn stop () u32 {
    // TODO
    return em.std.mem.zeroes(u32);
}

const em__Self = @This();

pub const EM__SPEC = struct {
    start: *const @TypeOf(em__Self.start) = &em__Self.start,
    stop: *const @TypeOf(em__Self.stop) = &em__Self.stop,
};

//->> zigem publish -- end of generated code
