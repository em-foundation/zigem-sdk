const std = @import("std");
const zgf = @import("zon_get_fields");

const Fs = @import("./Fs.zig");
const Heap = @import("./Heap.zig");

pub fn read(path: []const u8, obj_ptr: anytype) void {
    const txt = Fs.readFileZ(path);
    const ast = std.zig.Ast.parse(Heap.get(), txt, .zon) catch unreachable;
    _ = zgf.zonToStruct(obj_ptr, ast, Heap.get()) catch unreachable;
}
