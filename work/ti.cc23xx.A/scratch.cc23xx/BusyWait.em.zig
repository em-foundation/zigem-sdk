const em = @import("../../.gen/em.zig");

pub const em__unit = em.UnitSpec{
    .kind = .module,
    .upath = "scratch.cc23xx/BusyWait",
    .self = @This(),
};

pub var scalar = em__unit.declareConfig("scalar", u8){};

pub fn em__initH() void {
    scalar.initH(6);
}

pub fn wait(usecs: u32) void {
    if (usecs == 0) return;
    var dummy: u32 = undefined;
    const p: *volatile u32 = &dummy;
    for (0..(usecs * scalar.get())) |_| {
        p.* = 0;
    }
}
