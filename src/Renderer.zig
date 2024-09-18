const std = @import("std");

const Ast = std.zig.Ast;
const Fs = @import("Fs.zig");
const Heap = @import("Heap.zig");

pub fn exec(path: []const u8) !void {
    std.log.debug("\n\n", .{});
    const txt = Fs.readFileZ(try Fs.normalize(path));
    std.log.debug("len = {d}\n", .{txt.len});
    const ast = try Ast.parse(Heap.get(), txt, .zig);
    std.log.debug("ast = {any}\n", .{ast});
    const rend = try ast.render(Heap.get());
    std.log.debug("{s}", .{rend});
}
