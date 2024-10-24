pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    phy: em.Param(Phy),
};

pub const Phy = enum {
    NONE,
    BLE_1M,
    PROP_1M,
    PROP_250K,
};

pub const EM__META = struct {
    //
    pub const c_phy = em__C.phy;

    pub fn em__constructM() void {
        em__U.failif(em__C.phy.getM() == .NONE, "phy set to NONE");
    }
};

pub const EM__TARG = struct {
    //
    pub const phy = em__C.phy.unwrap();
};


//->> zigem publish #|abb7f1a34bc8a5c7023c6a2475fc829c6b428665bc58a8bb0d2bb4abfb5d689c|#

//->> EM__META publics
pub const c_phy = EM__META.c_phy;

//->> EM__TARG publics
pub const phy = EM__TARG.phy;

//->> zigem publish -- end of generated code
