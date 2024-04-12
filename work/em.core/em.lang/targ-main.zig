const std = @import("std");
const em = @import("em.zig");

pub fn exec(top: em.UnitSpec) !void {
    _ = @call(.auto, @field(top.self, "em__run"), .{});
    em.halt();
}
