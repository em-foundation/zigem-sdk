pub const EM__SPEC = {};

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Template(@This(), .{});

pub fn em__generateS(comptime name: []const u8) type {
    return struct {
        pub const EM__SPEC = {};

        pub const em__unit = em.Module(@This(), .{ .generated = true, .name = name });

        pub const c_active_low = @This().em__unit.Config("active_low", bool);

        pub const EM__HOST = {};

        pub fn em__initH() void {
            c_active_low.init(false);
        }

        pub const EM__TARG = {};

        const REG = em.REG;

        const active_low = c_active_low.unwrap();

        pub fn off() void {}

        pub fn on() void {}

        pub fn toggle() void {}
    };
}
