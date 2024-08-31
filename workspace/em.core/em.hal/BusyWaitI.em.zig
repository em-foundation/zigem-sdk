pub const em = @import("../../build/.gen/em.zig");
pub const em__U = em.interface(@This(), .{});

pub fn wait(usecs: u32) void {
    _ = usecs;
}
