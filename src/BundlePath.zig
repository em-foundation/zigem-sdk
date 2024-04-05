const std = @import("std");
const z2j = @import("utils/zon2json.zig");

const Fs = @import("./Fs.zig");
const Heap = @import("./Heap.zig");

var done_set = std.StringHashMap(void).init(Heap.get());
var path_list = std.ArrayList([]const u8).init(Heap.get());
var work_set = std.StringHashMap(void).init(Heap.get());

pub fn add(root_dir: []const u8, name: []const u8) !void {
    if (done_set.contains(name)) return;
    if (work_set.contains(name)) std.zig.fatal("bundle cycle in {s}", .{name});

    try work_set.put(name, {});

    // std.log.info("adding {s}", .{name});
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
    ) catch std.zig.fatal("couldn't parse {s}/bundle.zon", .{name});
    const jtxt = try json.toOwnedSlice();
    const parsed = try std.json.parseFromSlice(
        std.json.Value,
        Heap.get(),
        jtxt,
        .{},
    );
    const jobj = parsed.value;
    switch (jobj.object.get("requires").?) {
        .array => |reqs| for (reqs.items) |e| try add(root_dir, e.string),
        else => {},
    }

    _ = work_set.remove(name);
    try done_set.put(name, {});
    try path_list.insert(0, Fs.dirname(bpath));
}

pub fn get() [][]const u8 {
    return path_list.items;
}
