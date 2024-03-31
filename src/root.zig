const std = @import("std");
const testing = std.testing;

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "test2" {
    std.debug.print("*** in test2\n", .{});
    try testing.expect(add(3, 7) == 10);
}
