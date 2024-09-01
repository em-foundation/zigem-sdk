pub const em = @import("../../build/gen/em.zig");
pub const em__U = em.interface(@This(), .{});

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
