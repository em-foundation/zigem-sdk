const em = @import("../../.gen/em.zig");
const std = @import("std");

const type_map = @import("../../.gen/type_map.zig");

inline fn callAll(comptime fname: []const u8, ulist: []const em.Unit) void {
    inline for (ulist) |u| {
        if (@hasDecl(u.self, fname)) {
            _ = @call(.auto, @field(u.self, fname), .{});
        }
    }
}

pub fn exec(top: em.Unit) !void {
    const ulist_bot = mkUnitList(top, &.{});
    const ulist_top = revUnitList(ulist_bot);
    try validate(ulist_bot);
    callAll("em__initH", ulist_bot);
    callAll("em__configureH", ulist_top);
    callAll("em__constructH", ulist_top);
    callAll("em__generateH", ulist_bot);
    try genTarg(ulist_bot, top);
}

fn genDecls(unit: em.Unit, out: std.fs.File.Writer) !void {
    if (unit.legacy) return;
    const ti = @typeInfo(unit.self);
    inline for (ti.Struct.decls) |d| {
        const decl = @field(unit.self, d.name);
        if (std.mem.eql(u8, d.name, "EM__HOST")) break;
        const Decl = @TypeOf(decl);
        const ti_decl = @typeInfo(Decl);
        if (ti_decl == .Struct and @hasDecl(Decl, "_em__config")) {
            const tn_decl = @typeName(Decl);
            const idx = std.mem.indexOf(u8, tn_decl, ",").?;
            const tn = tn_decl[idx + 1 .. tn_decl.len - 1];
            try out.print("pub const @\"{s}\": {s} = {any};\n", .{ decl.dpath(), tn, decl.get() });
        }
    }
}

fn genDeclsOld(unit: em.Unit, out: std.fs.File.Writer) !void {
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

fn genTarg(ulist: []const em.Unit, top: em.Unit) !void {
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
    return em.sprint("em.Import.@\"{s}\"", .{upath});
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
