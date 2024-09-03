pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const HandlerFxn = em.Fxn(HandlerArg);
pub const HandlerArg = struct {
    arg: em.ptr_t,
};

pub const EM__TARG = struct {
    pub fn disable() void {
        return;
    }
    pub fn enable(msecs: u32, handler: HandlerFxn, arg: em.ptr_t) void {
        _ = msecs;
        _ = handler;
        _ = arg;
        return;
    }
};
