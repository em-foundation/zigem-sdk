const std = @import("std");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

pub fn deinit() void {
    arena.deinit();
}

pub fn get() std.mem.Allocator {
    return arena.allocator();
}
