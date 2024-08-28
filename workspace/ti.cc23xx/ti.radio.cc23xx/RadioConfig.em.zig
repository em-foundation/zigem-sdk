pub const em = @import("../../.gen/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    em__upath: []const u8,
    phy: em.Param(Phy),
};

pub const phy = em__C.phy;

pub const Phy = enum {
    NONE,
    BLE_1M,
    PROP_250K,
};

pub const EM__HOST = struct {
    //
    pub fn em__constructH() void {
        em__U.failif(phy.get() == .NONE, "phy set to NONE");
    }
};

pub const EM__TARG = struct {};
