const std = @import("std");
const em = @import("em.zig");

pub fn exec(top: em.UnitSpec) !void {
    _ = @call(.auto, @field(top.self, "em__init"), .{});
}

fn printCfgs(unit: em.UnitSpec) void {
    inline for (@typeInfo(unit.self).Struct.decls) |decl| {
        const fld = @field(unit.self, decl.name);
        const FT = @TypeOf(fld);
        const ti = @typeInfo(FT);
        if (ti == .Struct and @hasDecl(FT, "_em__config")) {
            std.debug.print("found {s}\n", .{decl.name});
            fld.print();
        }
    }
}
