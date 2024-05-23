pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Interface(@This(), .{});

pub const Handler = struct {
    arg: em.ptr_t,
};

pub fn disable() void {
    return;
}

pub fn enable(msecs: u32, handler: em.CB(Handler), arg: em.ptr_t) void {
    _ = msecs;
    _ = handler;
    _ = arg;
    return;
}
