const em = @import("../../.gen/em.zig");
const std = @import("std");

const type_map = @import("../../.gen/type_map.zig");
var used_set = std.StringHashMap(void).init(em.getHeap());

inline fn callAll(comptime fname: []const u8, ulist: []const em.Unit, filter_used: bool) void {
    inline for (ulist) |u| {
        if (@hasDecl(u.scope, fname) and (!filter_used or used_set.contains(u.upath))) {
            _ = @call(.auto, @field(u.scope, fname), .{});
        }
    }
}

pub fn exec(top: em.Unit) !void {
    const BuildH = em.Import.@"em__distro/BuildH";
    @setEvalBranchQuota(100_000);
    const ulist_bot = mkUnitList(top, mkUnitList(BuildH.em__unit, &.{}));
    const ulist_top = revUnitList(ulist_bot);
    try validate(ulist_bot);
    callAll("em__initH", ulist_bot, false);
    callAll("em__configureH", ulist_top, false);
    try mkUsedSet(top);
    try mkUsedSet(BuildH.em__unit);
    //var it = used_set.keyIterator();
    //while (it.next()) |k| em.print("{s}", .{k.*});
    callAll("em__constructH", ulist_top, true);
    callAll("em__generateH", ulist_bot, true);
    try genTarg(ulist_bot, ulist_top);
}

fn genCall(comptime fname: []const u8, ulist: []const em.Unit, mode: enum { all, first }, out: std.fs.File.Writer) !void {
    inline for (ulist) |u| {
        if (@hasDecl(u.self, fname)) {
            try out.print("    ", .{});
            try genImport(u.upath, out);
            try out.print(".{s}();\n", .{fname});
            if (mode == .first) break;
        }
    }
}

fn genDecls(unit: em.Unit, out: std.fs.File.Writer) !void {
    const ti = @typeInfo(unit.self);
    inline for (ti.Struct.decls) |d| {
        const decl = @field(unit.self, d.name);
        if (std.mem.eql(u8, d.name, "EM__TARG")) break;
        const Decl = @TypeOf(decl);
        const ti_decl = @typeInfo(Decl);
        if (ti_decl == .Struct and @hasDecl(Decl, "_em__builtin")) {
            try out.print("pub const @\"{s}\" = {s};\n", .{ decl.dpath(), decl.toString() });
        }
    }
}

fn genImport(path: []const u8, out: std.fs.File.Writer) !void {
    var it = std.mem.splitSequence(u8, path, "__");
    const un = it.first();
    if (std.mem.eql(u8, un, "em")) {
        try out.print("em", .{});
    } else {
        try out.print("em.unitScope(em.Import.@\"{s}\", .TARG)", .{un});
    }
    while (it.next()) |seg| {
        try out.print(".{s}", .{seg});
    }
}

fn genBuiltin(decl: anytype, out: std.fs.File.Writer) !bool {
    const tn_type = @typeName(decl.Type());
    if (comptime std.mem.startsWith(u8, tn_type, "em.core.em.lang.em.Ref(")) {
        try out.print("pub const @\"{s}\": em.Ref(", .{decl.dpath()});
        const idx = comptime std.mem.indexOf(u8, tn_type, "(").?;
        const rt = comptime if (idx == null) "<<null>>" else tn_type[idx.? + 1 .. tn_type.len - 1];
        const tun = comptime mkImportPath(rt, 2);
        try genImport(tun, out);
        try out.print(") = ", .{});
        try out.print("{s};\n", .{em.toStringAux(decl.get())});
        return true;
    }
    if (comptime std.mem.startsWith(u8, tn_type, "em.core.em.lang.em.Func(")) {
        try out.print("pub const @\"{s}\": em.Func(", .{decl.dpath()});
        const idx = comptime std.mem.indexOf(u8, tn_type, "(").?;
        const rt = comptime tn_type[idx + 1 .. tn_type.len - 1];
        const tun = comptime mkImportPath(rt, 2);
        try genImport(tun, out);
        try out.print(") = ", .{});
        try out.print("{s};\n", .{em.toStringAux(decl.get())});
        return true;
    }
    return false;
}

fn genTarg(ulist_bot: []const em.Unit, ulist_top: []const em.Unit) !void {
    const file = try std.fs.createFileAbsolute(em._targ_file, .{});
    const out = file.writer();
    const fmt =
        \\pub const _em_targ = {{}};
        \\
        \\const em = @import("em.zig");
        \\const std = @import("std");
        \\
        \\
    ;
    try out.print(fmt, .{});
    inline for (ulist_bot) |u| {
        if (u.kind == .module and !u.host_only and !u.legacy) {
            try out.print("// {s}\n", .{u.upath});
            try genDecls(u, out);
            try out.print("\n", .{});
        }
    }
    const fmt2 =
        \\pub fn em__done() void {{
        \\    var dummy: u32 = 0xCAFE;
        \\    const vp: *volatile u32 = &dummy;
        \\    while (true) {{
        \\        if (vp.* != 0) continue;
        \\    }}
        \\}}
        \\
    ;
    try out.print(fmt2, .{});
    try genTermFn("em__fail", ulist_top, out);
    try genTermFn("em__halt", ulist_top, out);
    try out.print("pub fn exec() void {{\n", .{});
    try genCall("em__reset", ulist_top, .first, out);
    try genCall("em__startup", ulist_bot, .all, out);
    try genCall("em__ready", ulist_top, .first, out);
    for (0..3) |_| {
        try out.print("    asm volatile (\"nop\");\n", .{});
    }
    try out.print("    ", .{});
    try genImport(ulist_top[0].upath, out);
    try out.print(".em__run();\n", .{});
    try out.print("    em.halt();\n", .{});
    try out.print("}}\n", .{});
    file.close();
}

fn genTermFn(comptime name: []const u8, ulist: []const em.Unit, out: std.fs.File.Writer) !void {
    try out.print("pub fn {s}() void {{\n", .{name});
    try genCall(name, ulist, .first, out);
    try out.print("    em__done();\n", .{});
    try out.print("}}\n", .{});
}

fn mkImportPath(comptime path: []const u8, comptime suf_cnt: usize) []const u8 {
    if (std.mem.startsWith(u8, path, "em.core.em.lang.em.Func(")) {
        return "em__" ++ path[std.mem.indexOf(u8, path, ".Func(").? + 1 ..];
    }
    if (std.mem.startsWith(u8, path, "em.core.em.lang.em.Ref(")) {
        return "em__" ++ path[std.mem.indexOf(u8, path, ".Ref(").? + 1 ..];
    }
    var idx: ?usize = path.len;
    inline for (1..suf_cnt) |_| {
        idx = std.mem.lastIndexOf(u8, path[0..idx.?], ".");
    }
    if (idx == null) return "<<importPath>>";
    const ut = path[0..idx.?];
    if (std.mem.eql(u8, ut, "em.core.em.lang.em")) {
        return "em__" ++ path[idx.? + 1 ..];
    }
    const un = @as([]const u8, @field(type_map, ut));
    return un ++ "__" ++ path[idx.? + 1 ..];
}

fn mkUnitList(comptime unit: em.Unit, comptime ulist: []const em.Unit) []const em.Unit {
    comptime var res = ulist;
    inline for (ulist) |u| {
        if (std.mem.eql(u8, u.upath, unit.upath)) return res;
    }
    std.debug.assert(@typeInfo(unit.self) == .Struct);
    if (!unit.legacy) {
        inline for (@typeInfo(unit.self).Struct.decls) |d| {
            const iu = @field(unit.self, d.name);
            if (@TypeOf(iu) == type and @typeInfo(iu) == .Struct and @hasDecl(iu, "em__unit")) {
                res = mkUnitList(@as(em.Unit, @field(iu, "em__unit")), res);
            }
        }
    }
    return res ++ .{unit};
}

fn mkUsedSet(comptime unit: em.Unit) !void {
    if (unit.kind == .composite or unit.kind == .template) return;
    if (!unit.legacy) {
        try used_set.put(unit.upath, {});
        inline for (@typeInfo(unit.self).Struct.decls) |d| {
            const ud = @field(unit.self, d.name);
            if (@TypeOf(ud) == type and @typeInfo(ud) == .Struct) {
                if (@hasDecl(ud, "em__unit")) {
                    try mkUsedSet(@as(em.Unit, @field(ud, "em__unit")));
                } else if (@hasDecl(ud, "_em_proxy")) {
                    try used_set.put(ud.get(), {});
                }
            }
            if (@TypeOf(ud) == type and @typeInfo(ud) == .Struct and @hasDecl(ud, "em__unit")) {
                try mkUsedSet(@as(em.Unit, @field(ud, "em__unit")));
            }
        }
    }
}

fn printDecls(unit: em.Unit) !void {
    const ti = @typeInfo(unit.self);
    inline for (ti.Struct.decls) |d| {
        const decl = @field(unit.self, d.name);
        const Decl = @TypeOf(decl);
        const ti_decl = @typeInfo(Decl);
        if (ti_decl == .Struct and @hasDecl(Decl, "_em__config")) {
            const tn = @typeName(Decl);
            em.print("{s}: {s} = {any}", .{ d.name, tn, decl.get() });
        }
    }
}

fn revUnitList(comptime ulist: []const em.Unit) []const em.Unit {
    comptime var res: []const em.Unit = &.{};
    inline for (ulist) |u| {
        res = .{u} ++ res;
    }
    return res;
}

fn validate(comptime ulist: []const em.Unit) !void {
    inline for (ulist) |u| {
        if (!u.generated) {
            const un = @as([]const u8, @field(type_map, @typeName(u.self)));
            if (!std.mem.eql(u8, u.upath, un)) {
                std.log.err("found unit named \"{s}\", expected \"{s}\"", .{ u.upath, un });
                std.process.exit(1);
            }
        }
    }
}
