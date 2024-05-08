pub const EM__SPEC = null;

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Interface(@This(), .{});

pub const Handler = *const fn (arg: em.ptr_t) void;

pub fn disable() void {
    return;
}

pub fn enable(msecs: u32, handler: Handler, arg: em.ptr_t) void {
    _ = msecs;
    _ = handler;
    _ = arg;
    return;
}
