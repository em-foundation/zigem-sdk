const std = @import("std");
const em = @import("../../.gen/em.zig");

var units = struct {
    const Self = @This();
    set: std.StringHashMap(void) = std.StringHashMap(void).init(em.getHeap()),
    fn add(self: *Self, upath: []const u8) void {
        if (self.set.contains(upath)) return;
        self.set.put(upath, {}) catch em.fail();
    }
}{};

pub fn exec(top: em.UnitSpec) !void {
    units.add(top.upath);
    if (@hasDecl(top.self, "em__init")) {
        _ = @call(.auto, @field(top.self, "em__init"), .{});
    }
    //genTarg();
    printCfgs(top);
}

//fn genDecls(out: std.fs.File.Writer, unit: em.UnitSpec) !void {}

fn genTarg() void {
    const file = std.fs.createFileAbsolute(em._targ_file, .{}) catch em.halt();
    const fmt =
        \\pub const _em_targ = {{}};
        \\
        \\const em = @import("em.zig");
    ;
    file.writer().print(fmt, .{}) catch unreachable;
    file.close();
}

fn printCfgs(unit: em.UnitSpec) void {
    if (!@hasDecl(unit.self, "em__decls")) return;
    const cs = @field(unit.self, "em__decls");
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
