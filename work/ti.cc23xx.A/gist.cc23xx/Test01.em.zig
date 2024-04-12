const std = @import("std");

const em = @import("../../.gen/em.zig");
const me = @This();

pub const em__unit = em.UnitSpec{
    .kind = .module,
    .upath = "gist.cc23xx/Test01",
    .self = me,
};

pub var c = em.CfgDecls(struct {
    max: em.Config(u32) = em.Config(u32).init(),
    min: em.Config(u32) = em.Config(u32).init(),
});

pub fn em__init() void {
    c.max.set(20);
    c.min.set(10);
}

pub fn em__run() void {
    c.max.set(20);
    em.REG(1111).* = c.max.get();
}
