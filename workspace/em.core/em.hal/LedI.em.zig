pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__TARG = struct {
    off: fn () void,
    on: fn () void,
    toggle: fn () void,
};

//#region zigem

//->> zigem publish #|51c3c1e7aca4d14155f6633e113eac8eef014b952183b2211f4c3ce478dd5270|#

pub fn off () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn on () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn toggle () void {
    // TODO
    return em.std.mem.zeroes(void);
}

const em__Self = @This();

pub const EM__SPEC = struct {
    off: *const @TypeOf(em__Self.off) = &em__Self.off,
    on: *const @TypeOf(em__Self.on) = &em__Self.on,
    toggle: *const @TypeOf(em__Self.toggle) = &em__Self.toggle,
};

//->> zigem publish -- end of generated code

//#endregion zigem
