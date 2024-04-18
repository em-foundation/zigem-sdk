const std = @import("std");
const z2j = @import("utils/zon2json.zig");

const Fs = @import("./Fs.zig");
const Heap = @import("./Heap.zig");

pub fn toJson(zpath: []const u8) !std.json.Value {
    var json = std.ArrayList(u8).init(Heap.get());
    var file = Fs.openFile(zpath);
    defer file.close();
    z2j.parse(
        Heap.get(),
        file.reader().any(),
        json.writer(),
        std.io.getStdErr().writer(),
        .{ .file_name = zpath },
    ) catch std.zig.fatal("couldn't parse {s}", .{zpath});
    const jtxt = try json.toOwnedSlice();
    const parsed = try std.json.parseFromSlice(
        std.json.Value,
        Heap.get(),
        jtxt,
        .{},
    );
    return parsed.value;
}
