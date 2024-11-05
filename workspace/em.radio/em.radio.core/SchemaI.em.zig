pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

const Ptr = *align(4) void;

pub const EM__META = struct {
    bindAppUpathM: fn (upath: []const u8) void,
};

pub const EM__TARG = struct {
    fetch: fn (resid: i8, optr: Ptr) void,
    store: fn (resid: i8, iptr: Ptr) void,
};


//->> zigem publish #|da52d5b9d711f98fdccc6aa43c2f66c291b1f69dd3a757f4a3c3e1e1a5f76978|#

pub fn bindAppUpathM (upath: []const u8) void {
    // TODO
    _ = upath;
    return em.std.mem.zeroes(void);
}

pub fn fetch (resid: i8, optr: Ptr) void {
    // TODO
    _ = resid;
    _ = optr;
    return em.std.mem.zeroes(void);
}

pub fn store (resid: i8, iptr: Ptr) void {
    // TODO
    _ = resid;
    _ = iptr;
    return em.std.mem.zeroes(void);
}

const em__Self = @This();

pub const EM__SPEC = struct {
    bindAppUpathM: *const @TypeOf(em__Self.bindAppUpathM) = &em__Self.bindAppUpathM,
    fetch: *const @TypeOf(em__Self.fetch) = &em__Self.fetch,
    store: *const @TypeOf(em__Self.store) = &em__Self.store,
};

//->> zigem publish -- end of generated code
