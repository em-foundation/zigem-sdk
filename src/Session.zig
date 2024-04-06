const std = @import("std");

const BundlePath = @import("BundlePath.zig");
const Fs = @import("Fs.zig");
const Heap = @import("Heap.zig");
const Out = @import("Out.zig");

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
    gen_root = Fs.join(&.{ cur_bpath, ".gen" });
    out_root = Fs.join(&.{ cur_bpath, ".out" });
    work_root = Fs.dirname(cur_bpath);
    if (mode == .CLEAN) {
        Fs.delete(gen_root);
        Fs.delete(out_root);
        return;
    }
    Fs.chdir(work_root);
    const bname = Fs.basename(cur_bpath);
    try BundlePath.add(work_root, "em.core");
    try BundlePath.add(work_root, bname);
    try genUnitBindings();
}

fn genUnitBindings() !void {
    var unit_map = std.StringHashMap([]const u8).init(Heap.get());
    for (BundlePath.get()) |bp| {
        var iter = Fs.openDir(bp).iterate();
        while (try iter.next()) |ent| {
            if (ent.kind != .directory) continue;
            var iter2 = Fs.openDir(Fs.join(&.{ bp, ent.name })).iterate();
            while (try iter2.next()) |ent2| {
                if (ent2.kind != .file) continue;
                const idx = std.mem.indexOf(u8, ent2.name, ".zig.em");
                if (idx == null) continue;
                const upath = try std.fmt.allocPrint(
                    Heap.get(),
                    "{s}/{s}",
                    .{
                        ent.name,
                        ent2.name[0..idx.?],
                    },
                );
                if (!unit_map.contains(upath)) try unit_map.put(upath, Fs.basename(bp));
            }
        }
    }
    Fs.mkdirs(cur_bpath, ".gen");
    var file = try Out.open(Fs.join(&.{ gen_root, "test.out" }));
    file.print("line1\n", .{});
    file.close();
    //var iter2 = unit_map.iterator();
    //while (iter2.next()) |ent2| {
    //    std.log.debug("k = {s}, v = {s}", .{ ent2.key_ptr.*, ent2.value_ptr.* });
    //}
}
