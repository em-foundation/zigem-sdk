pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const Access = enum { RW, RO, WO, EV };

pub fn Desc(T: type, acc: Access) type {
    return struct {
        pub const _acc = acc;
        pub const _T = T;
    };
}


//->> zigem publish #|91672b1eeec458c1fb73badbc337e9a310dc51b6d27b251d6cf99e9a05177981|#

//->> zigem publish -- end of generated code
