pub const std = @import("std");

pub const Import = @import("../../.gen/imports.zig");

pub const UnitName = @import("../../.gen/unit_names.zig").UnitName;

const targ = @import("../../.gen/targ.zig");
const type_map = @import("../../.gen/type_map.zig");

pub const assert = std.debug.assert;

pub const hosted = !@hasDecl(targ, "_em_targ");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

pub fn _ArrayD(dp: []const u8, T: type) type {
    return struct {
        const Self = @This();

        pub const _em__builtin = {};
        pub const _em__array = {};

        _is_virgin: bool = true,
        _list: std.ArrayList(T) = std.ArrayList(T).init(arena.allocator()),

        const _dpath = dp;

        pub fn Type(_: Self) type {
            return T;
        }

        pub fn addElem(self: *Self, elem: T) void {
            self._is_virgin = false;
            self._list.append(elem) catch fail();
        }

        pub fn alloc(self: Self, init: anytype) Ref(T) {
            const l = self._list.items.len;
            self._list.append(std.mem.zeroInit(T, init)) catch fail();
            const idx = std.mem.indexOf(u8, dp, "__").?;
            return Ref(T){ .upath = dp[0..idx], .aname = dp[idx + 2 ..], .idx = l };
        }

        pub fn dpath(_: Self) []const u8 {
            return _dpath;
        }

        pub fn getElem(self: Self, idx: usize) *T {
            return &self._list.items[idx];
        }

        pub fn indexOf(self: Self, elem: *T) usize {
            const p0 = @intFromPtr(&self._list.items[0]);
            const p1 = @intFromPtr(elem);
            return (p1 - p0) / @sizeOf(T);
        }

        pub fn len(self: Self) usize {
            return self._list.items.len;
        }

        pub fn list(self: Self) *std.ArrayList(T) {
            return &self._list;
        }

        pub fn setLen(self: *Self, l: usize) void {
            if (self.len() >= l) return;
            const save = self._is_virgin;
            for (0..l - self.len()) |_| self.addElem(std.mem.zeroes(T));
            self._is_virgin = save;
        }

        pub fn toString(self: Self) []const u8 {
            const tn = mkTypeName(T);
            if (self._is_virgin) {
                return sprint("std.mem.zeroes([{d}]{s})", .{ self.len(), tn });
            }
            var sb = StringH{};
            sb.add(sprint("[_]{s}{{", .{tn}));
            for (self._list.items) |e| {
                sb.add(sprint("    {s},\n", .{toStringAux(e)}));
            }
            return sprint("{s}}}", .{sb.get()});
        }

        pub fn unwrap(self: Self) []T {
            return self._list.items;
        }
    };
}

pub fn _ArrayV(T: type, comptime v: anytype) type {
    return struct {
        const Self = @This();

        const _val: [v.len]T = v;

        pub fn getElem(_: Self, idx: usize) *const T {
            return &_val[idx];
        }

        pub fn indexOf(_: Self, elem: *T) usize {
            const p0 = @intFromPtr(&_val[0]);
            const p1 = @intFromPtr(elem);
            return (p1 - p0) / @sizeOf(T);
        }

        pub fn len(_: Self) usize {
            return _val.len;
        }

        pub fn unwrap(_: Self) @TypeOf(_val) {
            return _val;
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

        pub const _em__builtin = {};
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
            return toStringAux(_val);
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

//pub fn Func(FT: type) type {
//    return struct {
//        _f: FT,
//        pub fn unwrap(self: @This()) FT {
//            return self._f;
//        }
//    };
//}

pub fn Func(FT: type) type {
    if (hosted) return struct {
        pub const _em__builtin = {};
        _upath: []const u8,
        _fname: []const u8,
        _fxn: ?FT,
        pub fn toString(self: @This()) []const u8 {
            const fmt =
                \\blk: {{
                \\    const u = @field(em.Import, "{s}");
                \\    const f = @field(u, "{s}");
                \\    break :blk f;
                \\}}
            ;
            const fval = sprint(fmt, .{ self._upath, self._fname });
            const tn = comptime @typeName(FT);
            const idx1 = comptime std.mem.indexOf(u8, tn, "(").?;
            const idx2 = comptime std.mem.indexOf(u8, tn, ")").?;
            const tn_par = comptime tn[idx1 + 1 .. idx2];
            return sprint("em.Func(*const fn({s}) void){{ ._fxn = {s} }}", .{ mkTypeImport(tn_par), fval });
        }
        pub fn unwrap(self: @This()) FT {
            return self._fxn.?;
        }
    } else return struct {
        _fxn: ?FT,
        pub fn unwrap(self: @This()) FT {
            return self._fxn.?;
        }
    };
}

//fn _FuncV(FT: type, comptime upath: []const u8, comptime fname: []const u8) type {
//    const u = @field(Import, upath);
//    const f = @field(u, fname);
//    return struct {
//        _f: FT = &f,
//        pub fn unwrap(self: @This()) FT {
//            return self._f;
//        }
//    };
//}

fn _ProxyD(dp: []const u8, I: type) type {
    return struct {
        const Self = @This();

        pub const _em__builtin = {};
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

        pub fn toString(_: Self) []const u8 {
            var it = std.mem.splitSequence(u8, _del, "__");
            var res = sprint("em.Import.@\"{s}\"", .{it.first()});
            while (it.next()) |seg| {
                res = sprint("{s}.{s}", .{ res, seg });
            }
            return res;
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

pub const ptr_t = ?*anyopaque;

pub fn Ref(T: type) type {
    if (hosted) return struct {
        const Self = @This();
        pub const _em__builtin = {};
        upath: []const u8,
        aname: []const u8,
        idx: usize,
        pub fn obj(self: Self) *T {
            const u = @field(Import, self.upath);
            const a = @field(u, self.aname);
            return @constCast(&(a.unwrap()[self.idx]));
        }
        pub fn toString(self: Self) []const u8 {
            const fmt =
                \\blk: {{
                \\    const u = @field(em.Import, "{s}");
                \\    const a = @field(u, "{s}");
                \\    break :blk @constCast(&(a.unwrap()[{d}]));
                \\}}
            ;
            const oval = sprint(fmt, .{ self.upath, self.aname, self.idx });
            return sprint("em.Ref({s}){{ .obj = {s} }}", .{ mkTypeName(T), oval });
        }
    } else return struct {
        obj: *T,
    };
}

pub const StringH = struct {
    const Self = @This();
    _txt: []const u8 = "",
    pub fn add(self: *Self, txt: []const u8) void {
        self._txt = sprint("{s}{s}", .{ self._txt, txt });
    }
    pub fn get(self: Self) []const u8 {
        return self._txt;
    }
};

pub const text_t = []const u8;

pub const UnitKind = enum {
    composite,
    interface,
    module,
    template,
};

pub const UnitOpts = struct {
    name: ?[]const u8 = null,
    host_only: bool = false,
    legacy: bool = false,
    generated: bool = false,
    inherits: type = void,
};

pub const Unit = struct {
    const Self = @This();

    kind: UnitKind,
    upath: []const u8,
    self: type,
    host_only: bool = false,
    legacy: bool = false,
    generated: bool = false,
    inherits: type = void,

    pub fn array(self: Self, name: []const u8, T: type) if (hosted) _ArrayD(self.extendPath(name), T) else _ArrayV(T, @field(targ, self.extendPath(name))) {
        const dname = self.extendPath(name);
        if (hosted) {
            return _ArrayD(dname, T){};
        } else {
            return _ArrayV(T, @field(targ, dname)){};
        }
    }

    pub fn config(self: Self, name: []const u8, T: type) if (hosted) _ConfigD(self.extendPath(name), T) else _ConfigV(T, @field(targ, self.extendPath(name))) {
        const dname = self.extendPath(name);
        if (hosted) {
            return _ConfigD(dname, T){};
        } else {
            return _ConfigV(T, @field(targ, dname)){};
        }
    }

    pub fn func(self: Self, name: []const u8, fxn: anytype) Func(@TypeOf(fxn)) {
        return Func(@TypeOf(fxn)){ ._upath = self.upath, ._fname = name, ._fxn = fxn };
    }

    pub fn proxy(self: Self, name: []const u8, I: type) if (hosted) _ProxyD(self.extendPath(name), I) else _ProxyV(@field(targ, self.extendPath(name))) {
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

pub fn CB(ParamsType: type) type {
    return *const fn (params: ParamsType) void;
}

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

pub fn fail() void {
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

pub fn halt() void {
    if (hosted) {
        std.log.info("em.halt", .{});
        std.process.exit(0);
    } else {
        targ.em__halt();
    }
}

fn mkTypeName(T: type) []const u8 {
    const ti = @typeInfo(T);
    const tn = @typeName(T);
    switch (ti) {
        .Enum => {
            return mkTypeImport(tn);
        },
        .Struct => {
            return mkTypeImport(tn);
        },
        else => {
            return tn;
        },
    }
}

fn mkTypeImport(comptime tn: []const u8) []const u8 {
    const idx = comptime std.mem.lastIndexOf(u8, tn, ".").?;
    const tun = comptime tn[0..idx];
    return "em.Import.@\"" ++ @as([]const u8, @field(type_map, tun)) ++ "\"." ++ tn[idx + 1 ..];
}

fn mkUnit(This: type, kind: UnitKind, opts: UnitOpts) Unit {
    const un = if (opts.name != null) opts.name.? else @as([]const u8, @field(type_map, @typeName(This)));
    return Unit{
        .generated = opts.generated,
        .host_only = opts.host_only,
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

pub fn toStringAux(v: anytype) []const u8 { // use zig fmt after host build
    const T = @TypeOf(v);
    const ti = @typeInfo(T);
    const tn = @typeName(T);
    switch (ti) {
        .Null => {
            return "null";
        },
        .Optional => {
            if (v == null) {
                return "null";
            } else {
                return "<<optional>>";
            }
        },
        .Bool, .Int, .ComptimeInt, .Float, .ComptimeFloat => {
            return sprint("@as({s}, {any})", .{ tn, v });
        },
        .Enum => {
            return sprint("{s}.{s}", .{ mkTypeImport(tn), @tagName(v) });
        },
        .Struct => {
            if (@hasDecl(T, "_em__builtin")) {
                return v.toString();
            } else {
                var res: []const u8 = sprint("{s}{{\n", .{mkTypeImport(tn)});
                inline for (ti.Struct.fields) |fld| {
                    res = sprint("    {s} .{s} = {s},\n", .{ res, fld.name, toStringAux(@field(v, fld.name)) });
                }
                return sprint("{s}}}\n", .{res});
            }
        },
        .Array => {
            var res: []const u8 = ".{";
            inline for (0..v.len) |i| {
                res = sprint("{s} {s},", .{ res, toStringAux(v[i]) });
            }
            return sprint("{s} }}", .{res});
        },
        .Pointer => |ptr_info| {
            if (ptr_info.size == .Slice and ptr_info.child == u8) {
                return sprint("\"{s}\"", .{v});
            } else {
                return "<<ptr>>";
            }
        },
        else => {
            return "<<unknown>>";
        },
    }
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
