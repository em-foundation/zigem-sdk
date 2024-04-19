const std = @import("std");

const Fs = @import("./Fs.zig");
const Heap = @import("./Heap.zig");
const Zon = @import("./Zon.zig");

var cur_jval = std.json.Value{ .object = std.StringArrayHashMap(std.json.Value).init(Heap.get()) };

pub fn add(spath: []const u8) !void {
    const jobj = try Zon.toJson(spath);
    std.debug.assert(jobj == .object);
    for (jobj.object.keys()) |k| {
        const v = jobj.object.get(k).?;
        try cur_jval.object.put(k, v);
    }
}

pub fn dump() !void {
    try std.json.stringify(cur_jval, .{ .whitespace = .indent_4 }, std.io.getStdOut().writer());
}

pub fn get() std.json.Value {
    return cur_jval;
}
