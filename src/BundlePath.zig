const std = @import("std");

const Fs = @import("./Fs.zig");
const Heap = @import("./Heap.zig");
const Zon = @import("./Zon.zig");

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
    const jobj = try Zon.toJson(bpath);
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
