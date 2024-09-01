pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub fn wait(usecs: u32) void {
    _ = usecs;
}
