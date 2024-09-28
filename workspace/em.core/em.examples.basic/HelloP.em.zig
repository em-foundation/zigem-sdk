pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub fn em__run() void {
    em.print("hello world\n", .{});
}
