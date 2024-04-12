const std = @import("std");

const em = @import("../../.gen/em.zig");
const me = @This();

pub const em__unit = em.UnitSpec{
    .kind = .module,
    .upath = "gist.cc23xx/Test01",
    .self = me,
};

pub fn em__init() void {
    std.log.debug("hi there", .{});
}

pub fn em__run() void {
    em.REG(1111).* = 10;
}
