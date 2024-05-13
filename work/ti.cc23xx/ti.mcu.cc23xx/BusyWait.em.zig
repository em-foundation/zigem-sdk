pub const EM__SPEC = null;

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{
    .inherits = em.Import.@"em.hal/BusyWaitI",
});

pub const c_scalar = em__unit.config("scalar", u8);

pub const EM__HOST = struct {};

pub fn em__initH() void {
    c_scalar.init(6);
}

pub const EM__TARG = struct {};

const scalar = c_scalar.unwrap();

pub fn wait(usecs: u32) void {
    if (usecs == 0) return;
    var dummy: u32 = undefined;
    const p: *volatile u32 = &dummy;
    for (0..(usecs * scalar)) |_| {
        p.* = 0;
    }
}
