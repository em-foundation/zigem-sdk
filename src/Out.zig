const std = @import("std");

const Fs = @import("Fs.zig");
const Heap = @import("Heap.zig");

const File = struct {
    _file: std.fs.File,
    pub fn close(this: @This()) void {
        this._file.close();
    }
    pub fn print(this: @This(), comptime fmt: []const u8, args: anytype) void {
        this._file.writer().print(fmt, args) catch unreachable;
    }
};

pub fn open(path: []const u8) !*File {
    var res = try Heap.get().create(File);
    const file = try std.fs.createFileAbsolute(path, .{});
    res._file = file;
    return res;
}
