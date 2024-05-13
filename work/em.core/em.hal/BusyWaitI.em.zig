pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Interface(@This(), .{});

pub fn wait(usecs: u32) void {
    _ = usecs;
}
