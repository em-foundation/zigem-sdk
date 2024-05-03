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
    const BuildC = em.Import.@"em__distro/BuildC";
    @setEvalBranchQuota(100_000);
    const ulist_bot = mkUnitList(top, mkUnitList(BuildC.em__unit, &.{}));
    const ulist_top = revUnitList(ulist_bot);
    try validate(ulist_bot);
    callAll("em__initH", ulist_bot);
    callAll("em__configureH", ulist_top);
    callAll("em__constructH", ulist_top);
    callAll("em__generateH", ulist_bot);
    try genTarg(ulist_bot, ulist_top);
}

fn genCall(comptime fname: []const u8, ulist: []const em.Unit, mode: enum { all, first }, out: std.fs.File.Writer) !void {
    inline for (ulist) |u| {
        if (@hasDecl(u.self, fname)) {
            try out.print("    ", .{});
            try genImport(u.upath, out);
            try out.print(".{s}();\n", .{fname});
            if (mode == .first) break;
        }
    }
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
            const ti2 = @typeInfo(decl.Type());
            switch (ti2) {
                .Enum, .Struct => {
                    const tn_type = @typeName(decl.Type());
                    const tun = comptime mkImportPath(tn_type, 2);
                    try out.print("pub const @\"{s}\": ", .{decl.dpath()});
                    try genImport(tun, out);
                    try out.print(" = ", .{});
                    try out.print("{s};\n", .{decl.toString()});
                },
                else => {
                    const tn_decl = @typeName(Decl);
                    const idx = std.mem.indexOf(u8, tn_decl, ",").?;
                    const tn = tn_decl[idx + 1 .. tn_decl.len - 1];
                    try out.print("pub const @\"{s}\": {s} = {s};\n", .{ decl.dpath(), tn, decl.toString() });
                },
            }
        } else if (ti_decl == .Struct and @hasDecl(Decl, "_em__proxy")) {
            try out.print("pub const @\"{s}\" = ", .{decl.dpath()});
            try genImport(decl.get(), out);
            try out.print(";\n", .{});
        }
    }
}

fn genImport(path: []const u8, out: std.fs.File.Writer) !void {
    var it = std.mem.splitSequence(u8, path, "__");
    try out.print("em.Import.@\"{s}\"", .{it.first()});
    while (it.next()) |seg| {
        try out.print(".{s}", .{seg});
    }
}

fn genTarg(ulist_bot: []const em.Unit, ulist_top: []const em.Unit) !void {
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
    inline for (ulist_bot) |u| {
        if (u.kind == .module) {
            try out.print("// {s}\n", .{u.upath});
            try genDecls(u, out);
            try out.print("\n", .{});
        }
    }
    const fmt2 =
        \\pub fn em__done() noreturn {{
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
    try out.print("pub fn exec() noreturn {{\n", .{});
    try genCall("em__reset", ulist_top, .first, out);
    try genCall("em__startup", ulist_bot, .all, out);
    try genCall("em__ready", ulist_top, .first, out);
    try out.print("    ", .{});
    try genImport(ulist_top[0].upath, out);
    try out.print(".em__run();\n", .{});
    try out.print("    em.halt();\n", .{});
    try out.print("}}\n", .{});
    file.close();
}

fn genTermFn(comptime name: []const u8, ulist: []const em.Unit, out: std.fs.File.Writer) !void {
    try out.print("pub fn {s}() noreturn {{\n", .{name});
    try genCall(name, ulist, .first, out);
    try out.print("    em__done();\n", .{});
    try out.print("}}\n", .{});
}

fn mkImportPath(comptime path: []const u8, comptime suf_cnt: usize) []const u8 {
    var idx: ?usize = path.len;
    inline for (1..suf_cnt) |_| {
        idx = std.mem.lastIndexOf(u8, path[0..idx.?], ".");
    }
    const un = @as([]const u8, @field(type_map, path[0..idx.?]));
    return un ++ "__" ++ path[idx.? + 1 ..];
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
