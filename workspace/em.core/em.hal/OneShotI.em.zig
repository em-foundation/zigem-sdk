pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const HandlerFxn = em.Fxn(HandlerArg);
pub const HandlerArg = struct {
    arg: em.ptr_t,
};

pub const EM__TARG = struct {
    disable: fn () void,
    enable: fn (msecs: u32, handler: HandlerFxn, arg: em.ptr_t) void,
    uenable: fn (usecs: u32, handler: HandlerFxn, arg: em.ptr_t) void,
};

//#region zigem

//->> zigem publish #|d2ea981c3b349d0aae1e801149109dc1aebec7d30a53abbb9782049f9d3ab3df|#

pub fn disable() void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn enable(msecs: u32, handler: HandlerFxn, arg: em.ptr_t) void {
    // TODO
    _ = msecs;
    _ = handler;
    _ = arg;
    return em.std.mem.zeroes(void);
}

pub fn uenable(usecs: u32, handler: HandlerFxn, arg: em.ptr_t) void {
    // TODO
    _ = usecs;
    _ = handler;
    _ = arg;
    return em.std.mem.zeroes(void);
}

const em__Self = @This();

pub const EM__SPEC = struct {
    disable: *const @TypeOf(em__Self.disable) = &em__Self.disable,
    enable: *const @TypeOf(em__Self.enable) = &em__Self.enable,
    uenable: *const @TypeOf(em__Self.uenable) = &em__Self.uenable,
};

//->> zigem publish -- end of generated code

//#endregion zigem
