pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__TARG = struct {
    startup: fn () void,
};

//#region zigem

//->> zigem publish #|c9ce771217648090ac2d64f8c504c0b2bdec75ae47aac16541998582a980bb2e|#

pub fn startup () void {
    // TODO
    return em.std.mem.zeroes(void);
}

const em__Self = @This();

pub const EM__SPEC = struct {
    startup: *const @TypeOf(em__Self.startup) = &em__Self.startup,
};

//->> zigem publish -- end of generated code

//#endregion zigem
