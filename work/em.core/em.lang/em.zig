const std = @import("std");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const heap = arena.allocator();

pub fn Config(T: type) type {
    return struct {
        const Self = @This();
        pub const _em__config = null;

        _val: ?T = null,

        pub fn get(self: Self) T {
            return self._val.?;
        }

        pub fn init(v: T) Self {
            return .{ ._val = v };
        }

        pub fn print(self: Self) void {
            std.log.debug("{any}", .{self._val});
        }

        pub fn set(self: *Self, v: T) void {
            self._val = v;
        }
    };
}

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

pub fn halt() noreturn {
    var dummy: u32 = 0xCAFE;
    const vp: *volatile u32 = &dummy;
    while (true) {
        if (vp.* != 0) continue;
    }
}

pub fn REG(adr: u32) *volatile u32 {
    const reg: *volatile u32 = @ptrFromInt(adr);
    return reg;
}
