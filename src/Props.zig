const std = @import("std");

const Fs = @import("./Fs.zig");
const Heap = @import("./Heap.zig");
const Ini = @import("./Ini.zig");

pub fn read(path: []const u8) void {
    const file = Fs.openFile(path);
    defer file.close();
    const parser = Ini.parse(Heap.get(), file.reader());
    _ = parser;
}
