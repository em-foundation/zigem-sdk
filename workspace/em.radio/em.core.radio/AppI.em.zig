pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__TARG = struct {
    onInit: fn () void,
    onActive: fn () void,
    onConnect: fn () void,
    onDisconnect: fn () void,
};

//->> zigem publish #|53972a41c3bc480832a2a3e5b5a8de210e5e93e2d4742716bcb5246ff72bf394|#

pub fn onInit () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn onActive () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn onConnect () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn onDisconnect () void {
    // TODO
    return em.std.mem.zeroes(void);
}

const em__Self = @This();

pub const EM__SPEC = struct {
    onInit: *const @TypeOf(em__Self.onInit) = &em__Self.onInit,
    onActive: *const @TypeOf(em__Self.onActive) = &em__Self.onActive,
    onConnect: *const @TypeOf(em__Self.onConnect) = &em__Self.onConnect,
    onDisconnect: *const @TypeOf(em__Self.onDisconnect) = &em__Self.onDisconnect,
};

//->> zigem publish -- end of generated code
