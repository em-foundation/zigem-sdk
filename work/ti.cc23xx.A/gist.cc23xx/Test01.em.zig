const em = @import("../../.gen/em.zig");

pub const em__unit = em.UnitSpec{
    .kind = .module,
    .upath = "gist.cc23xx/Test01",
    .self = @This(),
};

pub const BoardC = em.import.@"em__distro/BoardC";

const REG = em.REG;

const Obj = struct {
    c: u32,
    v: u32 = 0,
};

var obj1 = Obj{ .c = 11 };
var obj2 = Obj{ .c = 21 };

pub fn em__run() void {
    REG(0x40001000).* = obj1.c;
    REG(0x40002000).* = obj2.c;
    obj1.v = REG(0x40003000).*;
    obj2.v = REG(0x40004000).*;
    REG(0x40005000).* = obj1.v;
    REG(0x40006000).* = obj2.v;
}
