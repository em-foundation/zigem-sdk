pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const EM__HOST = struct {};

pub const EM__TARG = struct {};

pub fn em__run() void {
    em.halt();
}
