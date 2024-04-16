const std = @import("std");
const em = @import("../../.gen/em.zig");

fn mkUnitList(comptime unit: em.UnitSpec, comptime ulist: []const em.UnitSpec) []const em.UnitSpec {
    comptime var res = ulist;
    inline for (ulist) |u| {
        if (std.mem.eql(u8, u.upath, unit.upath)) return res;
    }
    inline for (unit.imports) |iu| {
        res = mkUnitList(iu, res);
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

pub fn exec(top: em.UnitSpec) !void {
    const ulist_bot = mkUnitList(top, &.{});
    inline for (ulist_bot) |u| {
        if (@hasDecl(u.self, "em__init")) {
            _ = @call(.auto, @field(u.self, "em__init"), .{});
        }
    }
    try genTarg(ulist_bot);
    //inline for (ulist_bot) |u| {
    //    printDecls(u);
    //}
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
    const file = try std.fs.createFileAbsolute(em.Unit._targ_file, .{});
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
        try out.print("pub var @\"{s}\" = .{{\n", .{u.upath});
        try genDecls(u, out);
        try out.print("}};\n\n", .{});
    }
    file.close();
}

fn printDecls(unit: em.UnitSpec) void {
    if (!@hasDecl(unit.self, "em__decls")) return;
    std.debug.print("\nunit {s}\n", .{unit.upath});
    const decl_struct = @field(unit.self, "em__decls");
    const Decl_Struct = @TypeOf(decl_struct);
    inline for (@typeInfo(Decl_Struct).Struct.fields) |fld| {
        const decl = @field(decl_struct, fld.name);
        const Decl = @TypeOf(decl);
        const ti = @typeInfo(Decl);
        if (ti == .Struct and @hasField(Decl, "_em__config")) {
            std.debug.print("\nconfig {s}\n", .{fld.name});
            decl.print();
        }
    }
}
