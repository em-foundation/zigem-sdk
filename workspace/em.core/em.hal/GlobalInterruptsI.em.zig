pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__TARG = struct {
    disable: fn () u32,
    enable: fn () void,
    isEnabled: fn () bool,
    restore: fn (key: u32) void,
};


//->> zigem publish #|0cdfe908e957c3c76ae2ebfbac3aaf5656e0461d27932a6a44809beb29390b7c|#

pub fn disable () u32 {
    // TODO
    return em.std.mem.zeroes(u32);
}

pub fn enable () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn isEnabled () bool {
    // TODO
    return em.std.mem.zeroes(bool);
}

pub fn restore (key: u32) void {
    // TODO
    _ = key;
    return em.std.mem.zeroes(void);
}

const em__Self = @This();

pub const EM__SPEC = struct {
    disable: *const @TypeOf(em__Self.disable) = &em__Self.disable,
    enable: *const @TypeOf(em__Self.enable) = &em__Self.enable,
    isEnabled: *const @TypeOf(em__Self.isEnabled) = &em__Self.isEnabled,
    restore: *const @TypeOf(em__Self.restore) = &em__Self.restore,
};

//->> zigem publish -- end of generated code
