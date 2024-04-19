const std = @import("std");

const BundlePath = @import("./BundlePath.zig");
const Fs = @import("./Fs.zig");
const Heap = @import("./Heap.zig");
const Out = @import("./Out.zig");
const Setup = @import("./Setup.zig");

pub const Mode = enum {
    BUILD,
    CLEAN,
};

var cur_bpath: []const u8 = undefined;
var cur_mode: Mode = undefined;
var gen_root: []const u8 = undefined;
var out_root: []const u8 = undefined;
var work_root: []const u8 = undefined;

pub fn activate(bundle: []const u8, mode: Mode, _: ?[]const u8) !void {
    cur_bpath = try Fs.normalize(bundle);
    cur_mode = mode;
    work_root = Fs.dirname(cur_bpath);
    gen_root = Fs.slashify(Fs.join(&.{ work_root, ".gen" }));
    out_root = Fs.slashify(Fs.join(&.{ work_root, ".out" }));
    Fs.delete(gen_root);
    Fs.delete(out_root);
    if (mode == .CLEAN) return;
    Fs.mkdirs(work_root, ".gen");
    Fs.mkdirs(work_root, ".out");
    Fs.chdir(work_root);
    const bname = Fs.basename(cur_bpath);
    try BundlePath.add(work_root, "em.core");
    try BundlePath.add(work_root, bname);
    try Setup.add(Fs.join(&.{ work_root, "local.zon" }));
}

pub fn generate(upath: []const u8) !void {
    try genEmStub();
    try genTarg();
    try genUnits();
    const uname = mkUname(upath);
    try genMainStub("host", uname, "pub");
    try genMainStub("targ", uname, "export");
}

fn genEmStub() !void {
    var file = try Out.open(Fs.join(&.{ gen_root, "em.zig" }));
    const fmt =
        \\pub usingnamespace @import("../em.core/em.lang/em.zig");
        \\
        \\pub const gen_root = "{s}";
        \\pub const out_root = "{s}";
        \\
        \\pub const _targ_file = "{0s}/targ.zig";
    ;
    file.print(fmt, .{ gen_root, out_root });
    file.close();
}

fn genMainStub(kind: []const u8, uname: []const u8, pre: []const u8) !void {
    const fname = try sprint(".main-{s}.zig", .{kind});
    var file = try Out.open(Fs.join(&.{ work_root, fname }));
    const idx = std.mem.indexOf(u8, uname, "/");
    const fmt =
        \\const em = @import(".gen/em.zig");
        \\
        \\{0s} fn main() void {{
        \\    @import("em.core/em.lang/{1s}-main.zig").exec(em.import.@"{2s}".{3s}.em__unit) catch em.halt();
        \\}}
    ;
    file.print(fmt, .{ pre, kind, uname[0..idx.?], uname[idx.? + 1 ..] });
    file.close();
}

fn genTarg() !void {
    var file = try Out.open(Fs.join(&.{ gen_root, "targ.zig" }));
    file.close();
}

fn genUnits() !void {
    var pkg_set = std.StringArrayHashMap(void).init(Heap.get());
    var file = try Out.open(Fs.join(&.{ gen_root, "units.zig" }));
    for (BundlePath.get()) |bp| {
        var iter = Fs.openDir(bp).iterate();
        const bname = Fs.basename(bp);
        while (try iter.next()) |ent| {
            if (ent.kind != .directory) continue;
            const pname = ent.name;
            if (pkg_set.contains(pname)) continue;
            try pkg_set.put(pname, {});
            var iter2 = Fs.openDir(Fs.join(&.{ bp, ent.name })).iterate();
            file.print("const @\"{s}__T\" = struct{{\n", .{pname});
            while (try iter2.next()) |ent2| {
                if (ent2.kind != .file) continue;
                const idx = std.mem.indexOf(u8, ent2.name, ".em.zig");
                if (idx == null) continue;
                file.print("    {s}: type = @import(\"../{s}/{s}/{s}\"),\n", .{ ent2.name[0..idx.?], bname, pname, ent2.name });
            }
            file.print("}};\n", .{});
            file.print("pub const @\"{0s}\" = @\"{0s}__T\"{{}};\n\n", .{pname});
        }
    }
    const distro_pkg = Setup.get().object.get("em__distro").?.string;
    file.print("pub const em__distro = @\"{s}\";\n", .{distro_pkg});
    file.close();
}

fn mkUname(upath: []const u8) []const u8 {
    const idx = std.mem.indexOf(u8, upath, ".em.zig");
    if (idx == null) return upath;
    return upath[0..idx.?];
}

fn sprint(comptime fmt: []const u8, args: anytype) ![]const u8 {
    return try std.fmt.allocPrint(Heap.get(), fmt, args);
}
