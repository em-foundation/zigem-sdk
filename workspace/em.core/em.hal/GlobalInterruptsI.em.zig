pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__TARG = struct {
    disable: fn () u32,
    enable: fn () void,
    isEnabled: fn () bool,
    restore: fn (key: u32) void,
};

//#region zigem

//->> zigem publish #|326987bd5181a370484d14c7883c5276c1ef65f15d92c270f3a438eea5bf6714|#

pub fn disable() u32 {
    // TODO
    return em.std.mem.zeroes(u32);
}

pub fn enable() void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn isEnabled() bool {
    // TODO
    return em.std.mem.zeroes(bool);
}

pub fn restore(key: u32) void {
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

//#endregion zigem
