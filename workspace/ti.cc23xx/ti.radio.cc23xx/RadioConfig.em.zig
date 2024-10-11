pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    phy: em.Param(Phy),
};
pub const c_phy = em__C.phy;

pub const Phy = enum {
    NONE,
    BLE_1M,
    PROP_250K,
};

pub const EM__META = struct {
    //
    pub fn em__constructH() void {
        em__U.failif(em__C.phy.getH() == .NONE, "phy set to NONE");
    }
};
