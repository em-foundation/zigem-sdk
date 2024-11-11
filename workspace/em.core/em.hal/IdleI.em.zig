pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__TARG = struct {
    exec: fn () void,
    wakeup: fn () void,
};


//->> zigem publish #|1d857d8cc6405e3810e94f16e172f89421166fd5306ce96eeea2105b118c2dc7|#

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
