pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub fn start() void {
    return;
}

pub fn stop(o_raw: ?*u32) u32 {
    _ = o_raw;
    return 0;
}
