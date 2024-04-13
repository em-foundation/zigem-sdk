const std = @import("std");
const em = @import("../../.gen/em.zig");

pub fn exec(top: em.UnitSpec) !void {
    if (@hasDecl(top.self, "em__init")) {
        _ = @call(.auto, @field(top.self, "em__init"), .{});
    }
    genTarg();
    printCfgs(top);
}

fn genTarg() void {
    const file = std.fs.createFileAbsolute(em._targ_file, .{}) catch em.halt();
    file.close();
}

fn printCfgs(unit: em.UnitSpec) void {
    if (!@hasDecl(unit.self, "c")) return;
    const cs = @field(unit.self, "c");
    const CS = @TypeOf(cs);
    inline for (@typeInfo(CS).Struct.fields) |fld| {
        const cfg = @field(cs, fld.name);
        const CfgT = @TypeOf(cfg);
        const ti = @typeInfo(CfgT);
        if (ti == .Struct and @hasDecl(CfgT, "_em__config")) {
            std.debug.print("\nconfig {s}\n", .{fld.name});
            cfg.print();
        }
    }
}
