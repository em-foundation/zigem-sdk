pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const Resource = em.import.@"em.radio.core/Resource";
pub const SchemaT = em.import.@"em.radio.core/SchemaT";

const FirstAppR = struct {
    data: Resource.Desc(i16, .RW),
};

pub const Schema = em__U.Generate("Schema", SchemaT, SchemaT.Params{ .ResT = FirstAppR });


//->> zigem publish #|4a28a5a16547b7deeedb01a38841d0b822927d3a283367ca66a50f6552474796|#

//->> zigem publish -- end of generated code
