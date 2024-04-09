const std = @import("std");
const em = @import("em.zig");

const Main = em.Unit.@"gist.cc23xx/Gist00_Min";

pub fn exec() !void {
    std.log.debug("hello", .{});
}
