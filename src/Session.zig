const std = @import("std");

const Fs = @import("./Fs.zig");
const Heap = @import("./Heap.zig");
const Zon = @import("./Zon.zig");

pub const Mode = enum {
    BUILD,
    CLEAN,
};

const BundleSpec = struct {
    name: []const u8 = "",
    requires: [5][]const u8 = [_][]const u8{&.{}} ** 5,
};

var cur_bpath: []const u8 = undefined;
var cur_mode: Mode = undefined;
var out_root: []const u8 = undefined;
var work_root: []const u8 = undefined;

pub fn activate(bundle: []const u8, mode: Mode, _: ?[]const u8) !void {
    cur_bpath = try Fs.normalize(bundle);
    cur_mode = mode;
    out_root = Fs.join(&.{ cur_bpath, ".out" });
    work_root = Fs.dirname(cur_bpath);
    if (mode == .CLEAN) {
        Fs.delete(out_root);
        return;
    }
    Fs.chdir(work_root);
    {
        const path = Fs.join(&.{ cur_bpath, "bundle.zon" });
        if (!Fs.exists(path)) std.zig.fatal("can't find {s}/bundle.zon", .{Fs.basename(cur_bpath)});
        var spec = BundleSpec{};
        Zon.read(path, &spec);
        std.log.debug("name = {s}, len = {d}", .{ spec.name, spec.requires.len });
        for (0..spec.requires.len) |i| std.log.debug("req[{d}] = {s}", .{ i, spec.requires[i] });

        //  Props.read(path);
        //        const txt = Fs.readFile(path);
        //        std.log.debug("{s}", .{txt});
    }
}
