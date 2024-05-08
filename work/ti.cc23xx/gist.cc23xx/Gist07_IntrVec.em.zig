pub const EM__SPEC = null;

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const EM__HOST = null;

pub const EM__TARG = null;

pub fn em__run() void {
    em.halt();
}
