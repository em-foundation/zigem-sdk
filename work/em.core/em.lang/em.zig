pub const std = @import("std");
pub const Unit = @import("../../.gen/units.zig");
const _Targ = @import("../../.gen/targ.zig");

pub const hosted = !@hasDecl(_Targ, "_em_targ");
pub const print = std.log.debug;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

pub fn Config(T: type) type {
    return struct {
        const Self = @This();

        comptime _em__config: void = void{},
        _val: ?T,

        pub fn get(self: Self) T {
            return self._val.?;
        }

        pub fn init() Self {
            return .{ ._val = null };
        }

        pub fn initV(v: T) Self {
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
    const Self = @This();

    kind: UnitKind,
    upath: []const u8,
    self: type,
    imports: []const UnitSpec = &.{},

    pub fn getSelf(self: Self) type {
        std.log.debug("hasDecl: {any}", .{@hasDecl(Unit, self.upath)});
        const u = @field(Unit, self.upath);
        const U = @TypeOf(u);
        std.log.debug("getSelf: {any}", .{u});
        return U;
    }

    pub fn declare(self: Self, Decls: type) Decls {
        if (hosted) {
            return Decls{};
        } else {
            //return @as(Decls, _Targ.@"gist.cc23xx/Test01");
            return @as(Decls, @field(_Targ, self.upath));
        }
    }

    pub fn import(_: Self, _: []const u8) type {}
};

pub fn fail() noreturn {
    halt();
}

pub fn getHeap() std.mem.Allocator {
    return arena.allocator();
}

pub fn getUnit(comptime upath: []const u8) void {
    if (@hasDecl(Unit, upath)) {
        const m = @field(Unit, upath);
        const M = @TypeOf(m);
        if (@hasDecl(M, "em__unit")) {
            const u = @field(Unit, "em__unit");
            const U = @TypeOf(u);
            std.log.debug("typeName = {s}", .{@typeName(U)});
        }
    }
}

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

pub fn sprint(comptime fmt: []const u8, args: anytype) []const u8 {
    return std.fmt.allocPrint(getHeap(), fmt, args) catch unreachable;
}

pub fn writeFile(dpath: []const u8, fname: []const u8, txt: []const u8) void {
    const fpath = sprint("{s}/{s}", .{ dpath, fname }) catch unreachable;
    const file = std.fs.createFileAbsolute(fpath, .{}) catch unreachable;
    file.write(txt) catch unreachable;
    file.close();
}
