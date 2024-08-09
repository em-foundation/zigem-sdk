const std = @import("std");

const Ini = @import("ini");

const Fs = @import("./Fs.zig");
const Heap = @import("./Heap.zig");
const Zon = @import("./Zon.zig");

var cur_jval = std.json.Value{ .object = std.StringArrayHashMap(std.json.Value).init(Heap.get()) };

var cur_props = std.StringHashMap([]const u8).init(Heap.get());

pub fn add(spath: []const u8) !void {
    const jobj = try Zon.toJson(spath);
    std.debug.assert(jobj == .object);
    for (jobj.object.keys()) |k| {
        const v = jobj.object.get(k).?;
        try cur_jval.object.put(k, v);
    }
}

pub fn addIni(path: []const u8) !void {
    var file = Fs.openFile(path);
    defer file.close();
    var parser = Ini.parse(Heap.get(), file.reader(), ";#");
    var pre: []const u8 = "";
    while (try parser.next()) |rec| {
        switch (rec) {
            .section => {
                const conc: []const []const u8 = &.{ rec.section, "." };
                pre = try std.mem.concat(Heap.get(), u8, conc);
            },
            .property => |kv| {
                const conc: []const []const u8 = &.{ pre, kv.key };
                const pname = try std.mem.concat(Heap.get(), u8, conc);
                try cur_props.put(pname, kv.value);
            },
            else => {},
        }
    }
}

pub fn dump() !void {
    try std.json.stringify(cur_jval, .{ .whitespace = .indent_4 }, std.io.getStdOut().writer());
}

pub fn get() std.json.Value {
    return cur_jval;
}

pub fn getProp(pname: []const u8) ?[]const u8 {
    return cur_props.get(pname);
}
