pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const Secs24p8 = u32;

pub fn Secs24p8_initMsecs(msecs: u32) Secs24p8 {
    return (msecs * 32) / 125;
}

pub fn Secs24p8_ZERO() Secs24p8 {
    return 0;
}
