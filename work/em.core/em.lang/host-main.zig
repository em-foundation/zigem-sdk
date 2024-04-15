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
    genTarg(ulist_bot);
    //inline for (ulist_bot) |u| {
    //    printDecls(u);
    //}
}

fn genTarg(ulist: []const em.UnitSpec) void {
    const file = std.fs.createFileAbsolute(em.Unit._targ_file, .{}) catch em.fail();
    const fmt =
        \\pub const _em_targ = {{}};
        \\
        \\const em = @import("em.zig");
        \\
        \\
    ;
    file.writer().print(fmt, .{}) catch unreachable;
    inline for (ulist) |u| {
        file.writer().print("pub var @\"{s}\" = .{{", .{u.upath}) catch em.fail();
        file.writer().print("}};\n", .{}) catch em.fail();
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
