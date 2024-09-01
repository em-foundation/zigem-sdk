pub const em = @import("../../zigem/gen/em.zig");
pub const em__U = em.interface(@This(), .{});

pub fn flush() void {
    return;
}

pub fn put(data: u8) void {
    _ = data;
    return;
}
