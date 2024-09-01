pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{
    .inherits = em.import.@"em.hal/BusyWaitI",
});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    scalar: em.Param(u8),
};

pub const EM__HOST = struct {
    //
    pub const scalar = em__C.scalar;

    pub fn em__initH() void {
        scalar.set(6);
    }
};

pub const EM__TARG = struct {
    //
    const scalar = em__C.scalar;

    pub fn wait(usecs: u32) void {
        if (usecs == 0) return;
        var dummy: u32 = undefined;
        const p: *volatile u32 = &dummy;
        for (0..(usecs * scalar)) |_| {
            p.* = 0;
        }
    }
};
