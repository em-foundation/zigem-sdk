const std = @import("std");

const cli = @import("zig-cli");

const heap = @import("./heap.zig");

pub fn main() !void {
    defer heap.deinit();

    const allctr = heap.get();
    const path = try std.fs.cwd().realpathAlloc(allctr, ".");
    std.debug.print("path = {s}\n", .{path});
}
