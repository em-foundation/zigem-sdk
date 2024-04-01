const std = @import("std");

const cli = @import("zig-cli");
const yaml = @import("yaml");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocr = arena.allocator();
    const path = try std.fs.cwd().realpathAlloc(allocr, ".");
    std.debug.print("path = {s}\n", .{path});
}
