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

test "01_json" {
    std.debug.print("\n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocr = gpa.allocator();
    const parsed = try readConfig(allocr, "my.json");
    defer parsed.deinit();
    const config = parsed.value;
    std.debug.print("\tname = {s}, val = {d}\n", .{ config.name, config.val });
}

test "02_dir_walk" {
    std.debug.print("\n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocr = gpa.allocator();
    var dir = try std.fs.cwd().openDir("work", .{ .iterate = true });
    defer dir.close();
    var walker = try dir.walk(allocr);
    defer walker.deinit();
    while (try walker.next()) |e| {
        std.debug.print("\t{s}\n", .{e.basename});
    }
}

test "03_cwd" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocr = arena.allocator();
    const path = try std.fs.cwd().realpathAlloc(allocr, ".");
    std.debug.print("path = {s}\n", .{path});
}
