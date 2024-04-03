const std = @import("std");
const z2j = @import("utils/zon2json.zig");

const Fs = @import("./Fs.zig");
const Heap = @import("./Heap.zig");

pub fn add(root_dir: []const u8, name: []const u8) void {
    const bpath = Fs.join(&.{ root_dir, name, "bundle.zon" });
    if (!Fs.exists(bpath)) std.zig.fatal("can't find file: {s}/bundle.zon", .{name});
    var json = std.ArrayList(u8).init(Heap.get());
    var file = Fs.openFile(bpath);
    defer file.close();
    z2j.parse(
        Heap.get(),
        file.reader().any(),
        json.writer(),
        std.io.getStdErr().writer(),
        .{ .file_name = name },
    ) catch unreachable;

    std.io.getStdOut().writer().writeAll(json.items) catch unreachable;
}
