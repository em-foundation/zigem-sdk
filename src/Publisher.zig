const std = @import("std");

const Fs = @import("./Fs.zig");
const Heap = @import("./Heap.zig");
const Out = @import("./Out.zig");

const print = std.debug.print;

pub fn exec(path: []const u8) !void {
    const norm = try Fs.normalize(path);
    const txt = Fs.readFileZ(norm);
    const mark = std.mem.indexOf(u8, txt, "//->>");
    const src = if (mark) |m| txt[0..m] else txt;
    const suf = mkSuffix(src);
    var file = try Out.open(norm);
    file.print("{s}{s}", .{ src, suf });
    file.close();
}

fn mkSuffix(src: []const u8) []const u8 {
    var sb = Out.StringBuf{};
    sb.add(Out.sprint("//->> zigem publish: {d}\n", .{src.len}));
    return sb.get();
}
