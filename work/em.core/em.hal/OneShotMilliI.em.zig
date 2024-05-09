pub const EM__SPEC = null;

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Interface(@This(), .{});

pub const Handler = em.CB(Handler_CB);
pub const Handler_CB = struct {
    arg: em.ptr_t,
};

pub fn disable() void {
    return;
}

pub fn enable(msecs: u32, cb: em.CB(Handler_CB), arg: em.ptr_t) void {
    _ = msecs;
    _ = cb;
    _ = arg;
    return;
}
