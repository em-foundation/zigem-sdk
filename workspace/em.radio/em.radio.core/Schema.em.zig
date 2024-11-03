pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {};

pub const Access = enum { RW, RO, WO, EV };

pub fn Resource(T: type, acc: Access) type {
    return struct {
        const _acc = acc;
        _ref: *T,
    };
}

pub const EM__META = struct {
    //
};

pub const EM__TARG = struct {
    //
};


//->> zigem publish #|d53f95626b9c218675dcb215304f5aae96a6ab12c36ca2b29660b444118d7cb5|#

//->> EM__META publics

//->> EM__TARG publics

//->> zigem publish -- end of generated code
