pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const Schema = em.import.@"em.radio.core/Schema";

pub const EM__SCHEMA = union(enum) {
    data: Schema.Resource(i16, .RW),
};

pub const EM__META = struct {
    //
};

pub const EM__TARG = struct {
    //
};


//->> zigem publish #|40a7969de32b68e3f4ba0d1c7b4404c5413d1c998fa1ccb218267ddcbb4c8d08|#

//->> EM__META publics

//->> EM__TARG publics

//->> zigem publish -- end of generated code
