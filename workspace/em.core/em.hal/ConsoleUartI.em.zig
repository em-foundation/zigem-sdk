pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__TARG = struct {
    flush: fn () void,
    put: fn (data: u8) void,
};

//#region zigem

//->> zigem publish #|b23527ebc56b47f60c03afe5548aaec1a3be803275428383bdc63a47b35bf32f|#

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

//#endregion zigem
