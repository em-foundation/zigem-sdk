pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__TARG = struct {
    exec: fn () void,
    wakeup: fn () void,
};

//#region zigem

//->> zigem publish #|442e6a657dca90a320ecb372ab0b6eea02139295d3280ab536e559a93edfa392|#

pub fn exec () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn wakeup () void {
    // TODO
    return em.std.mem.zeroes(void);
}

const em__Self = @This();

pub const EM__SPEC = struct {
    exec: *const @TypeOf(em__Self.exec) = &em__Self.exec,
    wakeup: *const @TypeOf(em__Self.wakeup) = &em__Self.wakeup,
};

//->> zigem publish -- end of generated code

//#endregion zigem
