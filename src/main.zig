const std = @import("std");

const Config = struct {
    name: []const u8,
    val: u8,
};

fn readConfig(allocr: std.mem.Allocator, path: []const u8) !std.json.Parsed(Config) {
    const data = try std.fs.cwd().readFileAlloc(allocr, path, 512);
    defer allocr.free(data);
    return std.json.parseFromSlice(Config, allocr, data, .{ .allocate = .alloc_always });
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocr = gpa.allocator();

    const parsed = try readConfig(allocr, "my.json");
    defer parsed.deinit();
    const config = parsed.value;
    std.debug.print("name = {s}, val = {d}\n", .{ config.name, config.val });
}
