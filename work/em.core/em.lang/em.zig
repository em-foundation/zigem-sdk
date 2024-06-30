pub const std = @import("std");

const domain_desc = @import("../../.gen/domain.zig");
pub const Domain = domain_desc.Domain;
pub const DOMAIN = domain_desc.DOMAIN;

pub const Import = @import("../../.gen/imports.zig");

pub const UnitName = @import("../../.gen/unit_names.zig").UnitName;

const targ = @import("../../.gen/targ.zig");
const type_map = @import("../../.gen/type_map.zig");

pub const assert = std.debug.assert;

pub const hosted = (DOMAIN == .HOST);

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

pub fn _ArrayD(dp: []const u8, T: type) type {
    return struct {
        const Self = @This();

        pub const _em__builtin = {};
        pub const _em__array = {};

        var _is_virgin: bool = true;
        var _list: std.ArrayList(T) = std.ArrayList(T).init(arena.allocator());

        const _dpath = dp;

        pub fn Type(_: Self) type {
            return T;
        }

        pub fn addElem(_: Self, elem: T) void {
            _is_virgin = false;
            _list.append(elem) catch fail();
        }

        pub fn ChildType(_: Self) type {
            return T;
        }

        pub fn childTypeName(_: Self) []const u8 {
            return mkTypeName(T);
        }

        pub fn dpath(_: Self) []const u8 {
            return _dpath;
        }

        pub fn getElem(_: Self, idx: usize) *T {
            return &_list.items[idx];
        }

        pub fn indexOf(_: Self, elem: *T) usize {
            const p0 = @intFromPtr(&_list.items[0]);
            const p1 = @intFromPtr(elem);
            return (p1 - p0) / @sizeOf(T);
        }

        pub fn isVirgin(_: Self) bool {
            return _is_virgin;
        }

        pub fn len(_: Self) usize {
            return _list.items.len;
        }

        pub fn list(_: Self) *std.ArrayList(T) {
            _is_virgin = false;
            return &_list;
        }

        pub fn setLen(self: Self, l: usize) void {
            if (self.len() >= l) return;
            const save = _is_virgin;
            for (0..l - self.len()) |_| self.addElem(std.mem.zeroes(T));
            _is_virgin = save;
        }

        pub fn toString(self: Self) []const u8 {
            const tn = mkTypeName(T);
            if (_is_virgin) {
                return sprint("std.mem.zeroes([{d}]{s})", .{ self.len(), tn });
            }
            var sb = StringH{};
            sb.add(sprint("[_]{s}{{", .{tn}));
            for (_list.items) |e| {
                sb.add(sprint("    {s},\n", .{toStringAux(e)}));
            }
            return sprint("{s}}}", .{sb.get()});
        }

        pub fn unwrap(_: Self) []T {
            _is_virgin = false;
            return _list.items;
        }
    };
}

pub fn _ArrayV(T: type, v: anytype) type {
    const ti = @typeInfo(@TypeOf(v));
    if (ti.Pointer.is_const) {
        return struct {
            const Self = @This();
            const _val = v;
            pub fn unwrap(_: Self) []T {
                return @constCast(_val);
            }
        };
    } else {
        return struct {
            const Self = @This();
            const _val = v;
            pub fn unwrap(_: Self) []T {
                return @constCast(_val);
            }
        };
    }
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

fn _ConfigV(dp: []const u8, T: type, v: T) type {
    return struct {
        const Self = @This();
        const _dpath = dp;
        const _val: T = v;
        pub fn unwrap(_: Self) T {
            return _val;
        }
    };
}

pub fn Func(FT: type) type {
    switch (DOMAIN) {
        .HOST => {
            return struct {
                pub const _em__builtin = {};
                _upath: []const u8,
                _fname: []const u8,
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
                pub fn typeName() []const u8 {
                    return sprint("em.Func({s})", .{mkTypeName(FT)});
                }
            };
        },
        .TARG => {
            return struct {
                _fxn: ?FT,
                pub fn unwrap(self: @This()) FT {
                    return self._fxn.?;
                }
            };
        },
    }
}

fn _FactoryD(dp: []const u8, T: type) type {
    return struct {
        const Self = @This();

        pub const _em__builtin = {};
        pub const _em__obj = {};

        pub const _dpath = dp;

        var _list: std.ArrayList(T) = std.ArrayList(T).init(arena.allocator());

        pub fn createH(_: Self, init: anytype) Ptr(T) {
            const l = _list.items.len;
            _list.append(std.mem.zeroInit(T, init)) catch fail();
            const idx = std.mem.indexOf(u8, dp, "__").?;
            return Ptr(T){ .upath = dp[0..idx], .aname = dp[idx + 2 ..], .idx = l, ._list = &_list };
        }

        pub fn dpath(_: Self) []const u8 {
            return _dpath;
        }

        pub fn objCount(_: Self) usize {
            return _list.items.len;
        }

        pub fn objTypeName(_: Self) []const u8 {
            return mkTypeName(T);
        }

        pub fn toString(_: Self) []const u8 {
            const tn = mkTypeName(T);
            var sb = StringH{};
            sb.add(sprint("[_]{s}{{", .{tn}));
            for (_list.items) |e| {
                sb.add(sprint("    {s},\n", .{toStringAux(e)}));
            }
            return sprint("{s}}}", .{sb.get()});
        }
    };
}

fn _FactoryV(dp: []const u8, T: type, a: []T) type {
    return struct {
        const Self = @This();
        const _dpath = dp;
        var _arr = a;
        pub fn all(_: Self) []T {
            return _arr[0..];
        }
        pub fn count(_: Self) usize {
            return a.len;
        }
        pub fn get(_: Self, idx: usize) *T {
            return &_arr[idx];
        }
    };
}

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
            var res = sprint("em.unitScope(em.Import.@\"{s}\")", .{it.first()});
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

fn _ProxyV(dp: []const u8, u: type) type {
    return struct {
        const Self = @This();
        const _dpath = dp;
        pub fn unwrap(_: Self) type {
            return u;
        }
    };
}

pub const ptr_t = ?*anyopaque;

pub fn Ptr(T: type) type {
    switch (DOMAIN) {
        .HOST => {
            return struct {
                const Self = @This();
                pub const _em__builtin = {};
                upath: []const u8,
                aname: []const u8,
                idx: usize,
                _list: ?*std.ArrayList(T),
                pub fn isNIL(self: Self) bool {
                    return self.upath.len == 0;
                }
                pub fn O(self: Self) *T {
                    return &self._list.?.items[self.idx];
                }
                pub fn setNIL(self: *Self) void {
                    self.upath = "";
                }
                pub fn toString(self: Self) []const u8 {
                    return if (self.isNIL()) "null" else sprint("@\"{s}__{s}__{d}\"", .{ self.upath, self.aname, self.idx });
                }
            };
        },
        .TARG => {
            return *T;
        },
    }
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

pub fn Table(comptime T: type) type {
    switch (DOMAIN) {
        .HOST => {
            return struct {
                const Self = @This();
                pub const _em__builtin = {};
                _list: std.ArrayList(T) = std.ArrayList(T).init(arena.allocator()),
                pub fn add(self: *Self, item: T) void {
                    self._list.append(item) catch fail();
                }
                pub fn items(self: *Self) []T {
                    return self._list.items;
                }
                pub fn toString(self: Self) []const u8 {
                    var res: []const u8 = sprint("&[_]{s}{{", .{mkTypeName(T)});
                    for (self._list.items) |item| {
                        res = sprint("{s} {s},", .{ res, toStringAux(item) });
                    }
                    return sprint("{s} }}", .{res});
                }
                pub fn typeName() []const u8 {
                    return sprint("em.Table({s})", .{mkTypeName(T)});
                }
            };
        },
        .TARG => {
            return []const T;
        },
    }
}

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

    _CT: type = void,
    kind: UnitKind,
    upath: []const u8,
    self: type,
    scope: type,
    host_only: bool = false,
    legacy: bool = false,
    generated: bool = false,
    inherits: type = void,

    pub fn array(self: Self, name: []const u8, T: type) if (DOMAIN == .HOST) _ArrayD(self.extendPath(name), T) else _ArrayV(T, @field(targ, self.extendPath(name))[0..]) {
        const dname = self.extendPath(name);
        if (DOMAIN == .HOST) {
            return _ArrayD(dname, T){};
        } else {
            return _ArrayV(T, @field(targ, dname)[0..]){};
        }
    }

    pub fn config(self: Self, name: []const u8, T: type) if (DOMAIN == .HOST) _ConfigD(self.extendPath(name), T) else _ConfigV(self.extendPath(name), T, @field(targ, self.extendPath(name))) {
        const dname = self.extendPath(name);
        if (DOMAIN == .HOST) {
            return _ConfigD(dname, T){};
        } else {
            return _ConfigV(dname, T, @field(targ, dname)){};
        }
    }

    pub fn config2(self: Self) self._CT {
        return std.mem.zeroInit(self._CT, .{});
    }

    pub fn factory(self: Self, name: []const u8, T: type) if (DOMAIN == .HOST) _FactoryD(self.extendPath(name), T) else _FactoryV(self.extendPath(name), T, @field(targ, self.extendPath(name))[0..]) {
        const dname = self.extendPath(name);
        if (DOMAIN == .HOST) {
            return _FactoryD(dname, T){};
        } else {
            return _FactoryV(dname, T, @field(targ, dname)[0..]){};
        }
    }

    pub fn func(self: Self, name: []const u8, FT: type) Func(FT) {
        return Func(FT){ ._upath = self.upath, ._fname = name };
    }

    pub fn proxy(self: Self, name: []const u8, I: type) if (DOMAIN == .HOST) _ProxyD(self.extendPath(name), I) else _ProxyV(self.extendPath(name), @field(targ, self.extendPath(name))) {
        const dname = self.extendPath(name);
        if (DOMAIN == .HOST) {
            return _ProxyD(dname, I){};
        } else {
            return _ProxyV(dname, @field(targ, dname)){};
        }
    }

    fn extendPath(self: Self, comptime name: []const u8) []const u8 {
        return self.upath ++ "__" ++ name;
    }

    pub fn Generate(self: Self, as_name: []const u8, comptime Template_Unit: type) type {
        return unitScope(Template_Unit.em__generateS(self.extendPath(as_name)));
    }

    pub fn import(_: Self, _: []const u8) type {}

    pub fn path(self: Self) []const u8 {
        return @field(type_map, @typeName(self.self));
    }
};

pub fn CB(ParamsType: type) type {
    switch (DOMAIN) {
        .HOST => {
            return struct {
                pub const _em__builtin = {};
                pub fn typeName() []const u8 {
                    return sprint("em.CB({s})", .{mkTypeName(ParamsType)});
                }
            };
        },
        .TARG => {
            return *const fn (params: ParamsType) void;
        },
    }
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

pub fn cwd() []const u8 {}

pub fn fail() void {
    switch (DOMAIN) {
        .HOST => {
            std.log.info("em.fail", .{});
            std.process.exit(1);
        },
        .TARG => {
            targ.em__fail();
        },
    }
}

pub fn getHeap() std.mem.Allocator {
    return arena.allocator();
}

pub fn halt() void {
    switch (DOMAIN) {
        .HOST => {
            std.log.info("em.halt", .{});
            std.process.exit(0);
        },
        .TARG => {
            targ.em__halt();
        },
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
            if (@hasDecl(T, "_em__builtin") and @hasDecl(T, "typeName")) {
                return @call(.auto, @field(T, "typeName"), .{});
            } else {
                return mkTypeImport(tn);
            }
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
        .scope = unitScope(This),
        .upath = un,
    };
}

pub fn normalize(path: []const u8) []const u8 {
    const res = std.fs.cwd().realpathAlloc(getHeap(), path) catch unreachable;
    return res;
}

pub fn reg(adr: u32) *volatile u32 {
    const r: *volatile u32 = @ptrFromInt(adr);
    return r;
}

pub fn reg16(adr: u32) *volatile u16 {
    const r: *volatile u16 = @ptrFromInt(adr);
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
            if (v) |val| {
                return toStringAux(val);
            } else {
                return "null";
            }
        },
        .Int => {
            if (ti.Int.signedness == .signed) {
                return sprint("@as({s}, {d})", .{ tn, v });
            } else if (ti.Int.bits <= 8) {
                return sprint("@as({s}, 0x{X:0>2})", .{ tn, v });
            } else if (ti.Int.bits <= 16) {
                return sprint("@as({s}, 0x{X:0>4})", .{ tn, v });
            } else if (ti.Int.bits <= 32) {
                return sprint("@as({s}, 0x{X:0>8})", .{ tn, v });
            } else {
                return sprint("@as({s}, 0x{X:0>16})", .{ tn, v });
            }
        },
        .Bool, .ComptimeInt, .Float, .ComptimeFloat => {
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

pub fn unitScope(U: type) type {
    return if (DOMAIN == .HOST) unitScope_H(U) else unitScope_T(U);
}

pub fn unitScope_H(U: type) type {
    const S = if (@hasDecl(U, "EM__HOST")) U.EM__HOST else struct {};
    return struct {
        const _UID = @typeName(U) ++ "_scope";
        pub usingnamespace U;
        pub usingnamespace S;
    };
}

pub fn unitScope_T(U: type) type {
    const S = if (@hasDecl(U, "EM__TARG")) U.EM__TARG else struct {};
    return struct {
        const _UID = @typeName(U) ++ "_scope";
        pub usingnamespace U;
        pub usingnamespace S;
    };
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

const Console = unitScope(@import("Console.em.zig"));

pub fn print(comptime fmt: []const u8, args: anytype) void {
    switch (DOMAIN) {
        .HOST => {
            std.log.debug(fmt, args);
        },
        .TARG => {
            std.fmt.format(Console.writer(), fmt, args) catch fail();
        },
    }
}

pub fn @"<>"(T: type, val: anytype) T {
    const ti = @typeInfo(T);
    const vi = @typeInfo(@TypeOf(val));
    switch (vi) {
        .Bool => {
            return @as(T, @intFromBool(val));
        },
        .ComptimeInt => {
            return @as(T, val);
        },
        .Int => {
            if (ti.Int.signedness == vi.Int.signedness) {
                return @as(T, @intCast(val));
            } else {
                const VT: std.builtin.Type = .{ .Int = .{ .bits = vi.Int.bits, .signedness = ti.Int.signedness } };
                return @as(T, @intCast(@as(@Type(VT), @bitCast(val))));
            }
        },
        else => {
            return val;
        },
    }
}

pub fn @"%%[>]"(v: anytype) void {
    Console.wrN(v);
}

const Debug = unitScope(@import("Debug.em.zig"));

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

// -------- EM__CONFIG -------- //

pub fn Module2(This: type, opts: UnitOpts) Unit {
    const un = if (opts.name != null) opts.name.? else @as([]const u8, @field(type_map, @typeName(This)));
    const CT = if (@hasDecl(This, "EM__CONFIG")) @field(This, "EM__CONFIG") else void;
    return Unit{
        ._CT = CT,
        .generated = opts.generated,
        .host_only = opts.host_only,
        .inherits = opts.inherits,
        .kind = .module,
        .legacy = opts.legacy,
        .self = This,
        .scope = unitScope(This),
        .upath = un,
    };
}

pub fn params(PT: type) *PT {
    return @constCast(&std.mem.zeroInit(PT, .{}));
}

pub fn Config(T: type) type {
    return if (DOMAIN == .HOST) Config_H(T) else Config_T(T);
}

pub fn Config_H(T: type) type {
    return struct {
        const Self = @This();

        pub const _em__builtin = {};
        pub const _em__config = {};

        _val: T,

        pub fn get(self: *Self) T {
            return self._val;
        }

        pub fn init(v: T) Config(T) {
            return Config(T){ ._val = v };
        }

        pub fn set(self: *Self, v: T) void {
            self._val = v;
        }

        pub fn toString(self: Self) []const u8 {
            return toStringAux(self._val);
        }

        pub fn Type(_: Self) type {
            return T;
        }
    };
}

pub fn Config_T(T: type) type {
    return struct {
        const Self = @This();

        _val: T,

        pub fn unwrap(self: Self) T {
            return self._val;
        }
    };
}
