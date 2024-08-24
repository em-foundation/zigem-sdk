const std = @import("std");

const Fs = @import("./Fs.zig");
const Heap = @import("./Heap.zig");
const Out = @import("./Out.zig");
const Props = @import("./Props.zig");

pub const Mode = enum {
    CLEAN,
    COMPILE,
    REFRESH,
};

var cur_mode: Mode = undefined;
var gen_root: []const u8 = undefined;
var out_root: []const u8 = undefined;
var work_root: []const u8 = undefined;

pub const ActivateParams = struct {
    work: []const u8,
    mode: Mode,
    bundle: ?[]const u8 = null,
    setup: ?[]const u8 = null,
};

pub fn activate(params: ActivateParams) !void {
    work_root = try Fs.normalize(params.work);
    cur_mode = params.mode;
    gen_root = Fs.slashify(Fs.join(&.{ work_root, ".gen" }));
    out_root = Fs.slashify(Fs.join(&.{ work_root, ".out" }));
    Fs.delete(gen_root);
    Fs.delete(out_root);
    if (cur_mode == .CLEAN) return;
    Fs.mkdirs(work_root, ".gen");
    Fs.mkdirs(work_root, ".out");
    Fs.chdir(work_root);
    Props.init(work_root, params.setup != null);
    try Props.addBundle("em.core");
    if (params.bundle) |bn| try Props.addBundle(bn);
    if (params.setup) |sn| try Props.addSetup(sn);
    try Props.addWorkspace();
    try Props.addBundle(getDistroBundle());
}

pub fn doBuild(upath: []const u8) !void {
    const uname = mkUname(upath);
    try genStubs("host", uname, "pub");
    try genStubs("targ", uname, "export");
}

pub fn doRefresh() !void {
    try genEmStub();
    try genProps();
    try genTarg();
    try genUnits();
}

fn genEmStub() !void {
    var file = try Out.open(Fs.join(&.{ gen_root, "em.zig" }));
    const fmt =
        \\pub usingnamespace @import("../em.core/em.lang/em.zig");
        \\
        \\pub const gen_root = "{0s}";
        \\pub const out_root = "{1s}";
        \\
        \\pub const _domain_file = "{0s}/domain.zig";
        \\pub const _targ_file = "{0s}/targ.zig";
        \\
        \\pub const hal = @import("../{2s}/{3s}/hal.zig");
    ;
    file.print(fmt, .{ gen_root, out_root, getDistroBundle(), getDistroPkg() });
    file.close();
}

fn genProps() !void {
    var file = try Out.open(Fs.join(&.{ gen_root, "props.zig" }));
    file.print("const std = @import(\"std\");\n\n", .{});
    file.print("pub const map = std.StaticStringMap([]const u8).initComptime(.{{\n", .{});
    var ent_iter = Props.getProps().iterator();
    while (ent_iter.next()) |e| {
        //        file.print("pub const @\"{s}\" = \"{s}\";\n", .{ e.key_ptr.*, e.value_ptr.* });
        file.print("    .{{ \"{s}\", \"{s}\" }},\n", .{ e.key_ptr.*, e.value_ptr.* });
    }
    file.print("}});\n", .{});
    file.close();
}

fn genStubs(kind: []const u8, uname: []const u8, pre: []const u8) !void {
    // .main-<kind>.zig
    const fn1 = try sprint(".main-{s}.zig", .{kind});
    var file = try Out.open(Fs.join(&.{ work_root, fn1 }));
    const fmt1 =
        \\{0s} fn main() void {{ @import(".gen/{1s}.zig").exec(); }}
    ;
    file.print(fmt1, .{ pre, kind });
    file.close();
    // .gen/<kind>.zig
    const fn2 = try sprint("{s}.zig", .{kind});
    file = try Out.open(Fs.join(&.{ gen_root, fn2 }));
    const fmt2 =
        \\const em = @import("./em.zig");
        \\
        \\pub fn exec() void {{
        \\    @import("../em.core/em.lang/{0s}-main.zig").exec(em.import.@"{1s}".em__U) catch em.fail();
        \\}}
    ;
    file.print(fmt2, .{ kind, uname });
    file.close();
}

fn genTarg() !void {
    var file = try Out.open(Fs.join(&.{ gen_root, "targ.zig" }));
    file.close();
}

fn genUnits() !void {
    const distro_pkg = getDistroPkg();
    var pkg_set = std.StringArrayHashMap(void).init(Heap.get());
    var type_map = std.StringArrayHashMap([]const u8).init(Heap.get());
    var file = try Out.open(Fs.join(&.{ gen_root, "imports.zig" }));
    const pre =
        \\const em = @import("./em.zig");
        \\
        \\
    ;
    file.print(pre, .{});
    for (Props.getBundles().items) |bp| {
        var iter = Fs.openDir(bp).iterate();
        const bname = Fs.basename(bp);
        while (try iter.next()) |ent| {
            if (ent.kind != .directory) continue;
            const pname = ent.name;
            const is_distro = std.mem.eql(u8, pname, distro_pkg);
            if (pkg_set.contains(pname)) continue;
            try pkg_set.put(pname, {});
            var iter2 = Fs.openDir(Fs.join(&.{ bp, ent.name })).iterate();
            while (try iter2.next()) |ent2| {
                if (ent2.kind != .file) continue;
                const idx = std.mem.indexOf(u8, ent2.name, ".em.zig");
                if (idx == null) continue;
                file.print("pub const @\"{0s}/{1s}\" = em.unitScope(@import(\"../{2s}/{0s}/{3s}\"));\n", .{ pname, ent2.name[0..idx.?], bname, ent2.name });
                const tn = try sprint("{s}.{s}.{s}.em", .{ bname, pname, ent2.name[0..idx.?] });
                const un = try sprint("{s}/{s}", .{ pname, ent2.name[0..idx.?] });
                try type_map.put(tn, un);
                if (is_distro) file.print("pub const @\"em__distro/{1s}\" = em.unitScope(@import(\"../{2s}/{0s}/{3s}\"));\n", .{ pname, ent2.name[0..idx.?], bname, ent2.name });
            }
        }
    }
    file.close();
    //
    file = try Out.open(Fs.join(&.{ gen_root, "domain.zig" }));
    file.print(
        \\pub const Domain = enum {{HOST, TARG}};
        \\pub const DOMAIN: Domain = .HOST;
        \\
    , .{});
    file.close();
    //
    file = try Out.open(Fs.join(&.{ gen_root, "type_map.zig" }));
    for (type_map.keys()) |tn| {
        const un = type_map.get(tn).?;
        file.print("pub const @\"{s}\" = \"{s}\";\n", .{ tn, un });
    }
    file.print("\n", .{});
    for (type_map.keys()) |tn| {
        const un = type_map.get(tn).?;
        file.print("pub const @\"{s}\" = \"{s}\";\n", .{ un, tn });
    }
    file.close();
    //
    file = try Out.open(Fs.join(&.{ gen_root, "unit_names.zig" }));
    file.print("pub const UnitName = enum{{\n", .{});
    for (type_map.keys()) |tn| {
        const un = type_map.get(tn).?;
        file.print("    @\"{s}\",\n", .{un});
    }
    file.print("}};\n", .{});
    file.close();
}

pub fn getBoard() []const u8 {
    return Props.getProps().get("em.lang.BoardKind").?;
}

fn getDistroBundle() []const u8 {
    const distro = Props.getProps().get("em.lang.DistroPackage").?;
    return distro[0..std.mem.indexOf(u8, distro, "://").?];
}

fn getDistroPkg() []const u8 {
    const distro = Props.getProps().get("em.lang.DistroPackage").?;
    return distro[std.mem.indexOf(u8, distro, "://").? + 3 ..];
}

pub fn getSetup() []const u8 {
    return Props.getProps().get("em.lang.SetupExtends").?;
}

pub fn getOutRoot() []const u8 {
    return out_root;
}

fn mkUname(upath: []const u8) []const u8 {
    const idx = std.mem.indexOf(u8, upath, ".em.zig");
    if (idx == null) return upath;
    return upath[0..idx.?];
}

fn sprint(comptime fmt: []const u8, args: anytype) ![]const u8 {
    return try std.fmt.allocPrint(Heap.get(), fmt, args);
}
