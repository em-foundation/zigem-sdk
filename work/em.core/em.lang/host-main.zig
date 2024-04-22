const em = @import("../../.gen/em.zig");
const std = @import("std");

inline fn callAll(comptime fname: []const u8, ulist: []const em.UnitSpec) void {
    inline for (ulist) |u| {
        if (@hasDecl(u.self, fname)) {
            _ = @call(.auto, @field(u.self, fname), .{});
        }
    }
}

pub fn exec(top: em.UnitSpec) !void {
    const ulist_bot = mkUnitList(top, &.{});
    const ulist_top = revUnitList(ulist_bot);
    callAll("em__initH", ulist_bot);
    callAll("em__configureH", ulist_top);
    callAll("em__constructH", ulist_top);
    callAll("em__generateH", ulist_bot);
    try genTarg(ulist_bot, top);
}

fn genDecls(unit: em.UnitSpec, out: std.fs.File.Writer) !void {
    if (unit.legacy) return;
    const ti = @typeInfo(unit.self);
    inline for (ti.Struct.decls) |d| {
        const decl = @field(unit.self, d.name);
        if (std.mem.startsWith(u8, d.name, "EM__")) break;
        const Decl = @TypeOf(decl);
        const ti_decl = @typeInfo(Decl);
        if (ti_decl == .Struct and @hasDecl(Decl, "_em__config")) {
            const tn_decl = @typeName(Decl);
            const idx = std.mem.indexOf(u8, tn_decl, ",").?;
            const tn = tn_decl[idx + 1 .. tn_decl.len - 1];
            try out.print("pub const @\"{s}\": {s} = {any};\n", .{ decl.nameH(), tn, decl.get() });
        }
    }
}

fn genDeclsOld(unit: em.UnitSpec, out: std.fs.File.Writer) !void {
    if (!@hasDecl(unit.self, "em__decls")) return;
    const decl_struct = @field(unit.self, "em__decls");
    const Decl_Struct = @TypeOf(decl_struct);
    inline for (@typeInfo(Decl_Struct).Struct.fields) |fld| {
        const decl = @field(decl_struct, fld.name);
        const Decl = @TypeOf(decl);
        const ti = @typeInfo(Decl);
        if (ti == .Struct and @hasField(Decl, "_em__config")) {
            const tn = @typeName(Decl);
            const idx = std.mem.indexOf(u8, tn, ".em.Config(").?;
            try out.print("    .{s} = {s}.initV({any}),\n", .{ fld.name, tn[idx + 1 ..], decl.get() });
        }
    }
}

fn genTarg(ulist: []const em.UnitSpec, top: em.UnitSpec) !void {
    const file = try std.fs.createFileAbsolute(em._targ_file, .{});
    const out = file.writer();
    const fmt =
        \\pub const _em_targ = {{}};
        \\
        \\const em = @import("em.zig");
        \\
        \\
    ;
    try out.print(fmt, .{});
    inline for (ulist) |u| {
        if (u.kind == .module) {
            try out.print("// {s}\n", .{u.upath});
            try genDecls(u, out);
            try out.print("\n", .{});
        }
    }
    try out.print("pub fn exec() void {{\n", .{});
    inline for (ulist) |u| {
        if (@hasDecl(u.self, "em__startup")) {
            try out.print("    {s}.em__startup();\n", .{mkImport(u.upath)});
        }
    }
    try out.print("    {s}.em__run();\n", .{mkImport(top.upath)});
    try out.print("    em.halt();\n", .{});
    try out.print("}}\n", .{});
    file.close();
}

fn mkImport(upath: []const u8) []const u8 {
    return em.sprint("em.import.@\"{s}\"", .{upath});
}

fn mkUnitList(comptime unit: em.UnitSpec, comptime ulist: []const em.UnitSpec) []const em.UnitSpec {
    comptime var res = ulist;
    inline for (ulist) |u| {
        if (std.mem.eql(u8, u.upath, unit.upath)) return res;
    }
    std.debug.assert(@typeInfo(unit.self) == .Struct);
    if (!unit.legacy) {
        inline for (@typeInfo(unit.self).Struct.decls) |d| {
            const iu = @field(unit.self, d.name);
            if (@TypeOf(iu) == type and @typeInfo(iu) == .Struct and @hasDecl(iu, "em__unit")) {
                res = mkUnitList(@as(em.UnitSpec, @field(iu, "em__unit")), res);
            }
        }
    }
    return res ++ .{unit};
}

fn printDecls(unit: em.UnitSpec) !void {
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

fn revUnitList(comptime ulist: []const em.UnitSpec) []const em.UnitSpec {
    comptime var res: []const em.UnitSpec = &.{};
    inline for (ulist) |u| {
        res = .{u} ++ res;
    }
    return res;
}
