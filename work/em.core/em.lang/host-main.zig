const em = @import("../../.gen/em.zig");
const std = @import("std");

const type_map = @import("../../.gen/type_map.zig");

var used_set = std.StringHashMap(void).init(em.getHeap());

inline fn callAll(comptime fname: []const u8, ulist: []const *em.Unit, filter_used: bool) void {
    inline for (ulist) |u| {
        if (!filter_used or used_set.contains(u.upath)) {
            const Scope = u.scope;
            if (@hasDecl(Scope, fname)) _ = @call(.auto, @field(Scope, fname), .{});
        }
    }
}

pub fn exec(top: *em.Unit) !void {
    const BuildH = em.import.@"em__distro/BuildH";
    @setEvalBranchQuota(100_000);
    const ulist_bot = mkUnitList(top, mkUnitList(BuildH.em__U, &.{}));
    const ulist_top = revUnitList(ulist_bot);
    try validate(ulist_bot);
    callAll("em__initH", ulist_bot, false);
    callAll("em__configureH", ulist_top, false);
    try mkUsedSet(top);
    try mkUsedSet(BuildH.em__U);
    callAll("em__constructH", ulist_top, false);
    callAll("em__generateH", ulist_top, false);
    try genDomain();
    try genTarg(ulist_bot, ulist_top);
    std.process.exit(0);
}

fn genCall(comptime fname: []const u8, ulist: []const *em.Unit, mode: enum { all, first }, out: std.fs.File.Writer) !void {
    inline for (ulist) |u| {
        if (@hasDecl(u.self, "EM__TARG") and @hasDecl(u.self.EM__TARG, fname)) {
            try out.print("    ", .{});
            try genImport(u.upath, out);
            try out.print(".{s}();\n", .{fname});
            if (mode == .first) break;
        }
    }
}

fn genConfig(unit: *em.Unit, out: std.fs.File.Writer) !void {
    if (!@hasDecl(unit.self, "em__C")) return;
    const C = @field(unit.self, "em__C");
    const ti = @typeInfo(@typeInfo(@TypeOf(C)).Pointer.child);
    inline for (ti.Struct.fields) |fld| {
        const cfld = &@field(C, fld.name);
        if (@typeInfo(@TypeOf(cfld.*)) == .Struct and @hasDecl(@TypeOf(cfld.*), "toStringDecls")) {
            try out.print("{s}", .{cfld.toStringDecls(unit.upath, fld.name)});
        }
    }
    const cfgpath = if (!unit.generated) unit.upath else mkConfigPath(@typeName(@TypeOf(C)));
    try out.print("pub const @\"{s}__config\" = em.import.@\"{s}\".EM__CONFIG{{\n", .{ unit.upath, cfgpath });
    inline for (ti.Struct.fields) |fld| {
        const cfld = &@field(C, fld.name);
        try out.print("    .{s} = {s},\n", .{ fld.name, em.toStringAux(cfld) });
    }
    try out.print("}};\n", .{});
}

fn genDomain() !void {
    const file = try std.fs.createFileAbsolute(em._domain_file, .{});
    const out = file.writer();
    try out.print(
        \\pub const Domain = enum {{HOST, TARG}};
        \\pub const DOMAIN: Domain = .TARG;
        \\
    , .{});
    file.close();
}

fn genImport(path: []const u8, out: std.fs.File.Writer) !void {
    var it = std.mem.splitSequence(u8, path, "__");
    const un = it.first();
    if (std.mem.eql(u8, un, "em")) {
        try out.print("em", .{});
    } else {
        try out.print("em.unitScope(em.import.@\"{s}\")", .{un});
    }
    while (it.next()) |seg| {
        try out.print(".{s}", .{seg});
    }
}

fn genTarg(ulist_bot: []const *em.Unit, ulist_top: []const *em.Unit) !void {
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
            try out.print("// {0s} {1s} {0s}\n", .{ "=" ** 8, u.upath });
            try genConfig(u, out);
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
    try out.print("    asm volatile (\".global __em__run\");\n", .{});
    try out.print("    asm volatile (\"__em__run:\");\n", .{});
    try out.print("    ", .{});
    try genImport(ulist_top[0].upath, out);
    try out.print(".em__run();\n", .{});
    try out.print("    em.halt();\n", .{});
    try out.print("}}\n", .{});
    file.close();
}

fn genTermFn(comptime name: []const u8, ulist: []const *em.Unit, out: std.fs.File.Writer) !void {
    try out.print("pub fn {s}() void {{\n", .{name});
    try genCall(name, ulist, .first, out);
    try out.print("    em__done();\n", .{});
    try out.print("}}\n", .{});
}

fn mkConfigPath(comptime tn: []const u8) []const u8 {
    const idx = comptime std.mem.lastIndexOf(u8, tn, ".").?;
    const tun = comptime tn[1..idx]; // skip leading '*'
    return @as([]const u8, @field(type_map, tun));
}

fn mkUnitList(comptime unit: *em.Unit, comptime ulist: []const *em.Unit) []const *em.Unit {
    comptime var res = ulist;
    inline for (ulist) |u| {
        if (std.mem.eql(u8, u.upath, unit.upath)) return res;
    }
    std.debug.assert(@typeInfo(unit.self) == .Struct);
    if (!unit.legacy) {
        inline for (@typeInfo(unit.self).Struct.decls) |d| {
            const iu = @field(unit.self, d.name);
            if (@TypeOf(iu) == type and @typeInfo(iu) == .Struct and @hasDecl(iu, "em__U")) {
                res = mkUnitList(@as(*em.Unit, @field(iu, "em__U")), res);
            }
        }
    }
    return res ++ .{unit};
}

fn mkUsedSet(comptime unit: *em.Unit) !void {
    if (unit.kind == .composite or unit.kind == .template) return;
    if (!unit.legacy) {
        try used_set.put(unit.upath, {});
        inline for (@typeInfo(unit.self).Struct.decls) |d| {
            const decl = @field(unit.self, d.name);
            const Decl = @TypeOf(decl);
            if (Decl == type and @typeInfo(decl) == .Struct and @hasDecl(decl, "em__U")) {
                try mkUsedSet(@as(*em.Unit, @field(decl, "em__U")));
            }
        }
        // TODO: handle em.Proxy configs
    }
}

fn revUnitList(comptime ulist: []const *em.Unit) []const *em.Unit {
    comptime var res: []const *em.Unit = &.{};
    inline for (ulist) |u| {
        res = .{u} ++ res;
    }
    return res;
}

fn validate(comptime ulist: []const *em.Unit) !void {
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
