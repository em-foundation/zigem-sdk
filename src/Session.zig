const std = @import("std");

const Heap = @import("./Heap.zig");
const Path = @import("./Path.zig");

pub const Mode = enum {
    BUILD,
    CLEAN,
};

var cur_bpath: []const u8 = undefined;
var cur_mode: Mode = undefined;
var out_root: []const u8 = undefined;
var work_root: []const u8 = undefined;

pub fn activate(bundle: []const u8, mode: Mode, _: ?[]const u8) !void {
    cur_bpath = try Path.normalize(bundle);
    cur_mode = mode;
    out_root = Path.join(&.{ cur_bpath, ".out" });
    work_root = Path.dirname(cur_bpath);
    std.log.debug("work = {s}", .{work_root});
    if (mode == .CLEAN) {
        Path.delete(out_root);
        return;
    }
}
