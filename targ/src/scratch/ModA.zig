const em = @import("../em.zig");

const ModB = @import("./ModB.zig");

pub const em__spec: em.Spec = .{
    .upath = "pkg/ModA",
    .uses = &.{
        em.Import{ .from = ModB, .as = "ModB" },
    },
};
