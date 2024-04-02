const std = @import("std");

const Fs = @import("./Fs.zig");
const Heap = @import("./Heap.zig");

pub const Mode = enum {
    BUILD,
    CLEAN,
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
    std.log.debug("{s}", .{Fs.cwd()});
}
