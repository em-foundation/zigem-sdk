const std = @import("std");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const heap = arena.allocator();

pub const UnitKind = enum {
    composite,
    interface,
    module,
};

pub const UnitSpec = struct {
    kind: UnitKind,
    upath: []const u8,
    self: type,
};

pub fn halt() void {
    var dummy: u32 = 0xCAFE;
    const vp: *volatile u32 = &dummy;
    while (vp.* != 0) {}
}

pub fn REG(adr: u32) *volatile u32 {
    const reg: *volatile u32 = @ptrFromInt(adr);
    return reg;
}
