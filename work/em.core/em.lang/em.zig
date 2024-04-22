pub const std = @import("std");

pub const import = @import("../../.gen/units.zig");

const targ = @import("../../.gen/targ.zig");

pub const hosted = !@hasDecl(targ, "_em_targ");
pub const print = std.log.debug;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

pub fn _ConfigD(cn: []const u8, T: type) type {
    return struct {
        const Self = @This();

        const S = struct {
            v: T,
        };

        const s = std.mem.zeroInit(S, .{});

        pub const _em__config = {};
        const _name = cn;
        var _val: T = s.v;

        pub fn get(_: Self) T {
            return _val;
        }

        pub fn initH(_: Self, v: T) void {
            _val = v;
        }

        pub fn nameH(_: Self) []const u8 {
            return _name;
        }

        pub fn print(_: Self) void {
            std.log.debug("{any}", .{_val});
        }

        pub fn set(_: Self, v: T) void {
            _val = v;
        }

        pub fn unwrap(_: Self) T {
            return s.v;
        }
    };
}

pub fn _ConfigV(T: type, v: T) type {
    return struct {
        const Self = @This();
        const _val: T = v;
        pub fn unwrap(_: Self) T {
            return _val;
        }
    };
}

pub fn _Config(T: type, v: T) type {
    return struct {
        const Self = @This();

        _val: T = v,

        pub fn get(self: Self) T {
            return self._val;
        }
    };
}

pub const UnitKind = enum {
    composite,
    interface,
    module,
    template,
};

pub const UnitSpec = struct {
    const Self = @This();

    kind: UnitKind,
    upath: []const u8,
    self: type,
    legacy: bool = false,

    pub fn declareConfig(self: Self, name: []const u8, T: type) type {
        const dname = self.upath ++ "__" ++ name;
        if (hosted) {
            return _ConfigD(dname, T);
        } else {
            return @as(type, @field(targ, dname));
        }
    }

    pub fn import(_: Self, _: []const u8) type {}
};

pub const DeclKind = enum {
    config,
    proxy,
    variable,
};

pub fn fail() noreturn {
    halt();
}

pub fn getHeap() std.mem.Allocator {
    return arena.allocator();
}

pub fn halt() noreturn {
    var dummy: u32 = 0xCAFE;
    const vp: *volatile u32 = &dummy;
    while (true) {
        if (vp.* != 0) continue;
    }
}

//pub fn import(comptime upath: []const u8) type {
//    std.debug.assert(@hasDecl(units, upath));
//    const U = @field(units, upath);
//    // @compileLog("import", U);
//    std.debug.assert(@hasDecl(U, "em__unit"));
//    return U;
//}

pub fn REG(adr: u32) *volatile u32 {
    const reg: *volatile u32 = @ptrFromInt(adr);
    return reg;
}

pub fn sprint(comptime fmt: []const u8, args: anytype) []const u8 {
    return std.fmt.allocPrint(getHeap(), fmt, args) catch unreachable;
}

pub fn writeFile(dpath: []const u8, fname: []const u8, txt: []const u8) void {
    const fpath = sprint("{s}/{s}", .{ dpath, fname });
    const file = std.fs.createFileAbsolute(fpath, .{}) catch unreachable;
    _ = file.write(txt) catch unreachable;
    file.close();
}
