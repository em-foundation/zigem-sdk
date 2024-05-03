pub const std = @import("std");

pub const Import = @import("../../.gen/imports.zig");

pub const UnitName = @import("../../.gen/unit_names.zig").UnitName;

const targ = @import("../../.gen/targ.zig");
const type_map = @import("../../.gen/type_map.zig");

pub const hosted = !@hasDecl(targ, "_em_targ");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

pub fn Array(T: type) @TypeOf(ArrayInit(T, [_]T{})) {
    return ArrayInit(T, [_]T{});
}

pub fn ArrayOf(T: type) type {
    if (hosted) return _ArrayD(T) else return _ArrayV(T, [_]T{});
}

pub fn ArrayInit(T: type, comptime v: anytype) if (hosted) _ArrayD(T) else _ArrayV(T, v) {
    if (hosted) return _ArrayD(T){} else return _ArrayV(T, v){};
}

pub fn _ArrayD(T: type) type {
    return struct {
        var _val = std.ArrayList(T).init(arena.allocator());
        pub fn unwrap(_: @This()) std.ArrayList(T) {
            return _val;
        }
    };
}

pub fn ArrayE(a: anytype) type {
    return struct {
        const T = @typeInfo(@TypeOf(a)).Array.child;
        var _arr: [a.len]T = a;
        pub fn unwrap(_: @This()) []T {
            return _arr[0..];
        }
    };
}

pub fn _ArrayV(T: type, v: anytype) type {
    return struct {
        const Self = @This();
        var _val: [v.len]T = v;
        pub fn unwrap(_: Self) []T {
            return _val[0..];
        }
    };
}

fn _ConfigD(dp: []const u8, T: type) type {
    return struct {
        const Self = @This();

        const S = struct {
            v: T,
        };

        const s = std.mem.zeroInit(S, .{});

        pub const _em__config = {};
        const _dpath = dp;
        var _val: T = s.v;

        pub fn get(_: Self) T {
            return _val;
        }

        pub fn init(_: Self, v: T) void {
            _val = v;
        }

        pub fn dpath(_: Self) []const u8 {
            return _dpath;
        }

        pub fn print(_: Self) void {
            std.log.debug("{s} = {any}", .{ _dpath, _val });
        }

        pub fn set(_: Self, v: T) void {
            _val = v;
        }

        pub fn toString(_: Self) []const u8 {
            const ti = @typeInfo(T);
            const vs = sprint("{any}", .{_val});
            switch (ti) {
                .Enum => {
                    const idx = std.mem.lastIndexOf(u8, vs, ".");
                    return vs[idx.? + 1 ..];
                },
                else => {
                    return vs;
                },
            }
        }

        pub fn Type(_: Self) type {
            return T;
        }

        pub fn unwrap(_: Self) T {
            return s.v;
        }
    };
}

fn _ConfigV(T: type, v: T) type {
    return struct {
        const Self = @This();
        const _val: T = v;
        pub fn unwrap(_: Self) T {
            return _val;
        }
    };
}

fn _ProxyD(dp: []const u8, I: type) type {
    return struct {
        const Self = @This();

        pub const _em__proxy = {};
        const _dpath = dp;
        var _del: []const u8 = toUnit(I).upath;

        pub fn get(_: Self) @TypeOf(_del) {
            return _del;
        }

        pub fn dpath(_: Self) []const u8 {
            return _dpath;
        }

        pub fn print(_: Self) void {
            std.log.debug("{s} = {s}", .{ _dpath, _del });
        }

        pub fn set(_: Self, u: type) void {
            _del = toUnit(u).upath;
        }

        pub fn unwrap(_: Self) type {
            return I;
        }
    };
}

fn _ProxyV(u: type) type {
    return struct {
        const Self = @This();
        pub fn unwrap(_: Self) type {
            return u;
        }
    };
}

pub const UnitKind = enum {
    composite,
    interface,
    module,
    template,
};

pub const UnitOpts = struct {
    name: ?[]const u8 = null,
    legacy: bool = false,
    generated: bool = false,
    inherits: type = void,
};

pub const Unit = struct {
    const Self = @This();

    kind: UnitKind,
    upath: []const u8,
    self: type,
    legacy: bool = false,
    generated: bool = false,
    inherits: type = void,

    pub fn Config(self: Self, name: []const u8, T: type) if (hosted) _ConfigD(self.extendPath(name), T) else _ConfigV(T, @field(targ, self.extendPath(name))) {
        const dname = self.extendPath(name);
        if (hosted) {
            return _ConfigD(dname, T){};
        } else {
            return _ConfigV(T, @field(targ, dname)){};
        }
    }

    pub fn Proxy(self: Self, name: []const u8, I: type) if (hosted) _ProxyD(self.extendPath(name), I) else _ProxyV(@field(targ, self.extendPath(name))) {
        const dname = self.extendPath(name);
        if (hosted) {
            return _ProxyD(dname, I){};
        } else {
            return _ProxyV(@field(targ, dname)){};
        }
    }

    fn extendPath(self: Self, comptime name: []const u8) []const u8 {
        return self.upath ++ "__" ++ name;
    }

    pub fn Generate(self: Self, as_name: []const u8, comptime Template_Unit: type) type {
        return Template_Unit.em__generateS(self.extendPath(as_name));
    }

    pub fn import(_: Self, _: []const u8) type {}

    pub fn path(self: Self) []const u8 {
        return @field(type_map, @typeName(self.self));
    }
};

pub fn Composite(This: type, opts: UnitOpts) Unit {
    return mkUnit(This, .composite, opts);
}

pub fn Interface(This: type, opts: UnitOpts) Unit {
    return mkUnit(This, .interface, opts);
}

pub fn Module(This: type, opts: UnitOpts) Unit {
    return mkUnit(This, .module, opts);
}

pub fn Template(This: type, opts: UnitOpts) Unit {
    return mkUnit(This, .template, opts);
}

pub fn fail() noreturn {
    if (hosted) {
        std.log.info("em.fail", .{});
        std.process.exit(1);
    } else {
        targ.em__fail();
    }
}

pub fn getHeap() std.mem.Allocator {
    return arena.allocator();
}

pub fn halt() noreturn {
    if (hosted) {
        std.log.info("em.halt", .{});
        std.process.exit(0);
    } else {
        targ.em__halt();
    }
}

fn mkUnit(This: type, kind: UnitKind, opts: UnitOpts) Unit {
    const un = if (opts.name != null) opts.name.? else @as([]const u8, @field(type_map, @typeName(This)));
    return Unit{
        .generated = opts.generated,
        .inherits = opts.inherits,
        .kind = kind,
        .legacy = opts.legacy,
        .self = This,
        .upath = un,
    };
}

pub fn reg(adr: u32) *volatile u32 {
    const r: *volatile u32 = @ptrFromInt(adr);
    return r;
}

pub fn sprint(comptime fmt: []const u8, args: anytype) []const u8 {
    return std.fmt.allocPrint(getHeap(), fmt, args) catch unreachable;
}

pub fn toUnit(U: type) Unit {
    return @as(Unit, @field(U, "em__unit"));
}

fn unitTypeName(unit: type) []const u8 {
    const tn: []const u8 = @typeName(unit);
    return tn[0 .. tn.len - 3];
}

pub fn writeFile(dpath: []const u8, fname: []const u8, txt: []const u8) void {
    const fpath = sprint("{s}/{s}", .{ dpath, fname });
    const file = std.fs.createFileAbsolute(fpath, .{}) catch unreachable;
    _ = file.write(txt) catch unreachable;
    file.close();
}

const Console = @import("Console.em.zig");

pub fn print(comptime fmt: []const u8, args: anytype) void {
    if (hosted) {
        std.log.debug(fmt, args);
    } else {
        std.fmt.format(Console.writer(), fmt, args) catch fail();
    }
}

pub fn @"%%[>]"(v: anytype) void {
    Console.wrN(v);
}

const Debug = @import("Debug.em.zig");

pub fn @"%%[a]"() void {
    Debug.pulse('A');
}
pub fn @"%%[a+]"() void {
    Debug.plus('A');
}
pub fn @"%%[a-]"() void {
    Debug.minus('A');
}
pub fn @"%%[a:]"(k: u8) void {
    Debug.mark('A', k);
}

pub fn @"%%[b]"() void {
    Debug.pulse('B');
}
pub fn @"%%[b+]"() void {
    Debug.plus('B');
}
pub fn @"%%[b-]"() void {
    Debug.minus('B');
}
pub fn @"%%[b:]"(k: u8) void {
    Debug.mark('B', k);
}

pub fn @"%%[c]"() void {
    Debug.pulse('C');
}
pub fn @"%%[c+]"() void {
    Debug.plus('C');
}
pub fn @"%%[c-]"() void {
    Debug.minus('C');
}
pub fn @"%%[c:]"(k: u8) void {
    Debug.mark('C', k);
}

pub fn @"%%[d]"() void {
    Debug.pulse('D');
}
pub fn @"%%[d+]"() void {
    Debug.plus('D');
}
pub fn @"%%[d-]"() void {
    Debug.minus('D');
}
pub fn @"%%[d:]"(k: u8) void {
    Debug.mark('D', k);
}
