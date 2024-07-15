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

pub const ptr_t = ?*anyopaque;

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

    pub fn config(self: Self, name: []const u8, T: type) if (DOMAIN == .HOST) _ConfigD(self.extendPath(name), T) else _ConfigV(self.extendPath(name), T, @field(targ, self.extendPath(name))) {
        const dname = self.extendPath(name);
        if (DOMAIN == .HOST) {
            return _ConfigD(dname, T){};
        } else {
            return _ConfigV(dname, T, @field(targ, dname)){};
        }
    }

    pub fn Config(self: Self, comptime CT: type) *CT {
        switch (DOMAIN) {
            .HOST => {
                const init = if (@hasField(CT, "em__upath")) .{ .em__upath = self.upath } else .{};
                return @constCast(&std.mem.zeroInit(CT, init));
            },
            .TARG => {
                return @constCast(&@field(targ, self.extendPath("config")));
            },
        }

        //switch (DOMAIN) {
        //    .HOST => {
        //        const flds = @typeInfo(CT).Struct.fields;
        //        comptime var new_flds: [flds.len + 1]std.builtin.Type.StructField = undefined;
        //        for (flds, 0..) |fld, i| {
        //            new_flds[i] = fld;
        //        }
        //        new_flds[flds.len] = .{
        //            .name = "em__upath",
        //            .type = []const u8,
        //            .default_value = null,
        //            .is_comptime = false,
        //            .alignment = 0,
        //        };
        //        const CT2 = @Type(.{ .Struct = .{
        //            .layout = .auto,
        //            .fields = new_flds[0..],
        //            .decls = &.{},
        //            .is_tuple = false,
        //            .backing_integer = null,
        //        } });
        //        return @constCast(&std.mem.zeroInit(CT2, .{ .em__upath = self.upath }));
        //    },
        //    .TARG => {
        //        return @constCast(&@field(targ, self.extendPath("config")));
        //    },
        //}
    }

    pub fn func(self: Self, name: []const u8, FT: type) Func(FT) {
        return Func(FT){ ._upath = self.upath, ._fname = name };
    }

    fn extendPath(self: Self, comptime name: []const u8) []const u8 {
        return self.upath ++ "__" ++ name;
    }

    pub fn Generate(self: Self, as_name: []const u8, comptime Template_Unit: type) type {
        return unitScope(Template_Unit.em__generateS(self.extendPath(as_name)));
    }

    pub fn path(self: Self) []const u8 {
        return @field(type_map, @typeName(self.self));
    }
};

pub fn CB(ParamsType: type) type {
    switch (DOMAIN) {
        .HOST => {
            return struct {
                pub const _em__builtin = {};
                pub fn toString(_: @This()) []const u8 { // TODO -- why???
                    return "<< CB >>";
                }
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

pub fn Composite(This: type, opts: UnitOpts) *Unit {
    return mkUnit(This, .composite, opts);
}

pub fn Interface(This: type, opts: UnitOpts) *Unit {
    return mkUnit(This, .interface, opts);
}

pub fn Module(This: type, opts: UnitOpts) *Unit {
    return mkUnit(This, .module, opts);
}

pub fn Template(This: type, opts: UnitOpts) *Unit {
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

fn mkUnit(This: type, kind: UnitKind, opts: UnitOpts) *Unit {
    const un = if (opts.name != null) opts.name.? else @as([]const u8, @field(type_map, @typeName(This)));
    return @constCast(&Unit{
        .generated = opts.generated,
        .host_only = opts.host_only,
        .inherits = opts.inherits,
        .kind = kind,
        .legacy = opts.legacy,
        .self = This,
        .scope = unitScope(This),
        .upath = un,
    });
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
            } else if (ptr_info.size == .One) {
                return toStringAux(v.*);
            } else {
                return "<<ptr>>";
            }
        },
        else => {
            return "<<unknown>>";
        },
    }
}

pub fn toUnit(U: type) *Unit {
    return @as(*Unit, @field(U, "em__U"));
}

pub fn unitScope(U: type) type {
    // TODO eliminate
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

pub const TargAccess = enum { RO, RW };

pub fn Array(T: type, comptime acc: TargAccess) type {
    return if (DOMAIN == .HOST) Array_H(T, acc) else Array_T(T, acc);
}

pub fn Array_H(T: type, comptime acc: TargAccess) type {
    return struct {
        const Self = @This();

        pub const _em__builtin = {};

        _dname: []const u8,
        _is_virgin: bool = true,
        _list: std.ArrayList(T) = std.ArrayList(T).init(arena.allocator()),

        pub fn addElem(self: *Self, elem: T) void {
            self._is_virgin = false;
            self._list.append(elem) catch fail();
        }

        pub fn elems(self: *Self) []T {
            self._is_virgin = false;
            return self._list.items;
        }

        pub fn setLen(self: *Self, len: usize) void {
            const sav = self._is_virgin;
            const l = self._list.items.len;
            if (len > l) {
                for (l..len) |_| {
                    self.addElem(std.mem.zeroes(T));
                }
            }
            self._is_virgin = sav;
        }

        pub fn toString(self: *const Self) []const u8 {
            const tn = mkTypeName(T);
            return sprint("em.Array_T({s}, .{s}){{ ._a = @constCast(&@\"{s}\")}}", .{ tn, @tagName(acc), self._dname });
        }

        pub fn toStringDecls(self: *Self, comptime upath: []const u8, comptime cname: []const u8) []const u8 {
            self._dname = upath ++ ".em__C." ++ cname;
            const tn = mkTypeName(T);
            var sb = StringH{};
            if (self._is_virgin) {
                sb.add(sprint("std.mem.zeroes([{d}]{s})", .{ self._list.items.len, tn }));
            } else {
                sb.add(sprint("[_]{s}{{", .{tn}));
                for (self._list.items) |e| {
                    sb.add(sprint("    {s},\n", .{toStringAux(e)}));
                }
                sb.add("}");
            }
            const ks = if (acc == .RO) "const" else "var";
            return sprint("pub {s} @\"{s}\" = {s};\n", .{ ks, self._dname, sb.get() });
        }
    };
}

pub fn Array_T(T: type, comptime acc: TargAccess) type {
    const A = if (acc == .RO) []const T else []T;
    return struct {
        const Self = @This();
        _a: A,
        pub fn len(self: Self) usize {
            return self._a.len;
        }
        pub fn unwrap(self: Self) A {
            return self._a;
        }
    };
}

pub fn Factory(T: type) type {
    return if (DOMAIN == .HOST) Factory_H(T) else Factory_T(T);
}

pub fn Factory_H(T: type) type {
    return struct {
        const Self = @This();

        pub const _em__builtin = {};

        _dname: []const u8,
        _list: std.ArrayList(T) = std.ArrayList(T).init(arena.allocator()),

        pub fn createH(self: *Self, init: anytype) Obj_H(T) {
            const l = self._list.items.len;
            self._list.append(std.mem.zeroInit(T, init)) catch fail();
            return Obj_H(T){ ._fty = self, ._idx = l };
        }

        pub fn objCount(self: *const Self) usize {
            return self._list.items.len;
        }

        pub fn objGet(self: *const Self, idx: usize) *T {
            return @constCast(&self._list.items[idx]);
        }

        pub fn objTypeName(_: Self) []const u8 {
            return mkTypeName(T);
        }

        pub fn ref(self: *Self) *Factory_H(T) {
            return @constCast(self);
        }

        pub fn toString(self: *const Self) []const u8 {
            const tn = mkTypeName(T);
            return sprint("em.Factory_T({s}){{ ._arr = @constCast(&@\"{s}__OBJARR\"), ._len = {d}}}", .{ tn, self._dname, self.objCount() });
        }

        pub fn toStringDecls(self: *Self, comptime upath: []const u8, comptime cname: []const u8) []const u8 {
            self._dname = upath ++ "_em__C_" ++ cname;
            var sb = StringH{};
            const tn = mkTypeName(T);
            sb.add(sprint("pub var @\"{s}__OBJARR\" = [_]{s}{{\n", .{ self._dname, tn }));
            for (self._list.items) |e| {
                sb.add(sprint("    {s},\n", .{toStringAux(e)}));
            }
            sb.add("};\n");
            const size_txt =
                \\export const @"{0s}__BASE" = &@"{0s}__OBJARR";
                \\const @"{0s}__SIZE" = std.fmt.comptimePrint("{{d}}", .{{@sizeOf({1s})}});
                \\
                \\
            ;
            sb.add(sprint(size_txt, .{ self._dname, tn }));
            for (0..self.objCount()) |i| {
                const abs_txt =
                    \\comptime {{
                    \\    asm (".globl \"{0s}${1d}\"");
                    \\    asm ("\"{0s}${1d}\" = \".gen.targ.{0s}__OBJARR\" + {1d} * " ++ @"{0s}__SIZE");
                    \\}}
                    \\extern const @"{0s}${1d}": usize;
                    \\const @"{0s}__{1d}": *{2s} = @constCast(@ptrCast(&@"{0s}${1d}"));
                    \\
                    \\
                ;
                sb.add(sprint(abs_txt, .{ self._dname, i, tn }));
            }
            return sb.get();
        }
    };
}

pub fn Factory_T(T: type) type {
    return extern struct {
        const Self = @This();
        _arr: [*]T,
        _len: usize,
        pub fn objAll(self: Self) []T {
            return self._arr[0..self._len];
        }
        pub fn objCount(self: Self) usize {
            return self._len;
        }
        pub fn objGet(self: Self, idx: usize) *T {
            return @constCast(&self._arr[idx]);
        }
    };
}

pub fn Obj(T: type) type {
    return if (DOMAIN == .HOST) Obj_H(T) else Obj_T(T);
}

pub fn Obj_H(T: type) type {
    return struct {
        const Self = @This();

        pub const _em__builtin = {};

        _fty: ?*Factory_H(T),
        _idx: usize,
        pub fn getIdx(self: *const Self) usize {
            return self._idx;
        }
        pub fn O(self: *const Self) *T {
            return self._fty.?.objGet(self._idx);
        }
        pub fn toString(self: *const Self) []const u8 {
            return if (self._fty == null) "null" else sprint("@\"{s}__{d}\"", .{ self._fty.?._dname, self._idx });
        }
        pub fn typeName() []const u8 {
            return sprint("*{s}", .{mkTypeName(T)});
        }
    };
}

pub fn Obj_T(T: type) type {
    return *T;
}

pub fn Param(T: type) type {
    return if (DOMAIN == .HOST) Param_H(T) else Param_T(T);
}

pub fn Param_H(T: type) type {
    return struct {
        const Self = @This();

        pub const _em__builtin = {};
        pub const _em__config = {};

        _val: T,

        pub fn get(self: *Self) T {
            return self._val;
        }

        pub fn ref(self: *Self) *Param_H(T) {
            return self;
        }

        pub fn init(v: T) Param(T) {
            return Param(T){ ._val = v };
        }

        pub fn set(self: *Self, v: T) void {
            self._val = v;
        }

        pub fn toString(self: *const Self) []const u8 {
            return sprint("em.Param_T({s}){{ ._val = {s} }}", .{ mkTypeName(T), toStringAux(self._val) });
        }

        pub fn Type(_: Self) type {
            return T;
        }

        pub fn unwrap(self: *const Self) T {
            return self._val;
        }
    };
}

pub fn Param_T(T: type) type {
    return struct {
        const Self = @This();

        _val: T,

        pub fn ref(self: *Self) *Param_T(T) {
            return self;
        }

        pub fn unwrap(self: *const Self) T {
            return self._val;
        }
    };
}

pub fn Proxy(I: type) type {
    return if (DOMAIN == .HOST) Proxy_H(I) else Proxy_T(I);
}

pub fn Proxy_H(I: type) type {
    return struct {
        const Self = @This();

        pub const _em__builtin = {};
        pub const _em__config = {};

        _prx: []const u8 = I.em__U.upath,

        pub fn get(self: *Self) I {
            return self._prx;
        }

        pub fn ref(self: *Self) *Proxy_H(I) {
            return self;
        }

        pub fn set(self: *Self, x: anytype) void {
            self._prx = x.em__U.upath;
        }

        pub fn toString(self: *const Self) []const u8 {
            var it = std.mem.splitSequence(u8, self._prx, "__");
            var sb = StringH{};
            sb.add(sprint("em.Proxy_T(em.Import.@\"{s}\"){{ ._prx = em.Import.@\"{s}\"", .{ I.em__U.upath, it.first() }));
            while (it.next()) |seg| {
                sb.add(sprint(".{s}", .{seg}));
            }
            sb.add(".em__U }");
            return sb.get();
        }
    };
}

pub fn Proxy_T(I: type) type {
    return struct {
        const Self = @This();

        _prx: *Unit,

        pub fn ref(self: *Self) *Proxy_T(I) {
            return self;
        }

        pub fn unwrap(comptime self: *const Self) @TypeOf(unitScope_T(self._prx.self)) {
            return unitScope_T(self._prx.self);
        }
    };
}
