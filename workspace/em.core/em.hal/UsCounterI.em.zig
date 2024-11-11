pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__TARG = struct {
    set: fn (time_us: u32) void,
    spin: fn () void,
    start: fn () void,
    stop: fn (o_raw: ?*u32) u32,
};

//->> zigem publish #|7d823a0a1b226fd0f3a2d60ca7ce53ce8726cccdebfa173fd214edc5f7b6d609|#

pub fn set(time_us: u32) void {
    // TODO
    _ = time_us;
    return em.std.mem.zeroes(void);
}

pub fn spin() void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn start() void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn stop(o_raw: ?*u32) u32 {
    // TODO
    _ = o_raw;
    return em.std.mem.zeroes(u32);
}

const em__Self = @This();

pub const EM__SPEC = struct {
    set: *const @TypeOf(em__Self.set) = &em__Self.set,
    spin: *const @TypeOf(em__Self.spin) = &em__Self.spin,
    start: *const @TypeOf(em__Self.start) = &em__Self.start,
    stop: *const @TypeOf(em__Self.stop) = &em__Self.stop,
};

//->> zigem publish -- end of generated code
