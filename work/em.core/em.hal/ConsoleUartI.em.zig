pub const EM__SPEC = null;

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Interface(@This(), .{});

pub fn flush() void {
    return;
}

pub fn put(data: u8) void {
    _ = data;
    return;
}
