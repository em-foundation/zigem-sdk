pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__TARG = struct {
    start: fn () void,
    stop: fn () u32,
};

//#region zigem

//->> zigem publish #|816fd929aac36e0e00ae635fe44e4a9325212fec5a7236379284427f9cd04c8f|#

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

//#endregion zigem
