const std = @import("std");

const em = @import("../../.gen/em.zig");
const me = @This();

pub const em__unit = em.UnitSpec{
    .kind = .module,
    .upath = "ti.mcu.cc23xx/BusyWait",
    .self = me,
};

pub const d_ = &em__decls;
pub var em__decls = em__unit.declare(struct {
    scalar: em.Config(u8) = em.Config(u8).initV(6),
});

pub fn wait(usecs: u32) void {
    if (usecs == 0) return;
    var dummy: u32 = undefined;
    const p: *volatile u32 = &dummy;
    for (0..(usecs * d_.scalar.get())) |_| {
        p.* = 0;
    }
}
