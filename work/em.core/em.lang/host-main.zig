const std = @import("std");
const em = @import("../../.gen/em.zig");

//var units = struct {
//    const Self = @This();
//    set: std.StringHashMap(void) = std.StringHashMap(void).init(em.getHeap()),
//    fn add(self: *Self, upath: []const u8) void {
//        if (self.set.contains(upath)) return;
//        self.set.put(upath, {}) catch em.fail();
//    }
//}{};

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
    const ulist_top = revUnitList(ulist_bot);
    std.log.debug("ulist_bot", .{});
    inline for (ulist_bot) |u| {
        std.log.debug("{s}", .{u.upath});
    }
    std.log.debug("ulist_top", .{});
    inline for (ulist_top) |u| {
        std.log.debug("{s}", .{u.upath});
    }

    //inline for (mkUnitList(top, &.{})) |u| {
    //    std.log.debug("unit {s}", .{u.upath});
    //}

    //inline for (top.imports) |iu| {
    //    std.log.debug("imports {s}", .{iu.upath});
    //}

    if (@hasDecl(top.self, "em__init")) {
        _ = @call(.auto, @field(top.self, "em__init"), .{});
    }
    //genTarg();
    //printCfgs(top);
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
        if (ti == .Struct and @hasField(CfgT, "_em__config")) {
            std.debug.print("\nconfig {s}\n", .{fld.name});
            cfg.print();
        }
    }
}
