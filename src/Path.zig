const std = @import("std");

const Heap = @import("./Heap.zig");

pub fn delete(abs_path: []const u8) void {
    std.fs.deleteTreeAbsolute(abs_path) catch return;
}

pub fn dirname(path: []const u8) []const u8 {
    return if (std.fs.path.dirname(path)) |dn| dn else "";
}

pub fn join(paths: []const []const u8) []const u8 {
    const res = std.fs.path.join(Heap.get(), paths) catch unreachable;
    return res;
}

pub fn normalize(path: []const u8) ![]const u8 {
    return std.fs.cwd().realpathAlloc(Heap.get(), path);
}
