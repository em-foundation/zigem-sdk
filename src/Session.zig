const std = @import("std");

const Heap = @import("./Heap.zig");
const Path = @import("./Path.zig");

pub const Mode = enum {
    BUILD,
    CLEAN,
};

var cur_bpath: []const u8 = undefined;
var cur_mode: Mode = undefined;
var cur_out_root: []const u8 = undefined;

pub fn activate(bundle: []const u8, mode: Mode, _: ?[]const u8) !void {
    cur_bpath = try Path.normalize(bundle);
    cur_mode = mode;
    const a = [_][]const u8{ cur_bpath, ".out" };
    cur_out_root = Path.join(&a);
    if (mode == .CLEAN) {
        Path.delete(cur_out_root);
        return;
    }
}
