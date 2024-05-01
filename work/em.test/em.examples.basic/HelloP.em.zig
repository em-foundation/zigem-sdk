pub const EM__SPEC = {};

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const EM__HOST = {};

pub const EM__TARG = {};

pub fn em__run() void {
    em.print("hello world\n", .{});
}
