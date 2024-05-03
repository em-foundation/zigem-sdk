pub const EM__SPEC = null;

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Interface(@This(), .{});

pub fn disable() u32 {
    return 0;
}

pub fn enable() void {
    return;
}

pub fn restore(key: u32) void {
    _ = key;
    return;
}
