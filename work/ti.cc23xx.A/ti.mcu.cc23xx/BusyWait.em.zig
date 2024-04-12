const std = @import("std");

const em = @import("../../.gen/em.zig");
const me = @This();

pub const em__unit = em.UnitSpec{
    .kind = .module,
    .upath = "ti.mcu.cc23xx/BusyWait",
    .self = me,
};

const scalar = 6;

pub fn wait(usecs: u32) void {
    if (usecs == 0) return;
    var dummy: u32 = undefined;
    const p: *volatile u32 = &dummy;
    for (0..(usecs * scalar)) |_| {
        p.* = 0;
    }
}
