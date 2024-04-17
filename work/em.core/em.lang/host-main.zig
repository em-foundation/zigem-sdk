const em = @import("../../.gen/em.zig");
const std = @import("std");

pub fn exec(top: em.UnitSpec) !void {
    const ulist_bot = mkUnitList(top, &.{});
    inline for (ulist_bot) |u| {
        if (@hasDecl(u.self, "em__initH")) {
            _ = @call(.auto, @field(u.self, "em__initH"), .{});
        }
    }
    inline for (ulist_bot) |u| {
        if (@hasDecl(u.self, "em__generateH")) {
            _ = @call(.auto, @field(u.self, "em__generateH"), .{});
        }
    }
    try genTarg(ulist_bot);
}

fn genDecls(unit: em.UnitSpec, out: std.fs.File.Writer) !void {
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

fn genTarg(ulist: []const em.UnitSpec) !void {
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
            try out.print("pub var @\"{s}\" = .{{\n", .{u.upath});
            try genDecls(u, out);
            try out.print("}};\n\n", .{});
        }
    }
    file.close();
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

fn revUnitList(comptime ulist: []const em.UnitSpec) []const em.UnitSpec {
    comptime var res: []const em.UnitSpec = &.{};
    inline for (ulist) |u| {
        res = .{u} ++ res;
    }
    return res;
}
