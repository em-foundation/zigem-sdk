pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const Resource = em.import.@"em.core.radio/Resource";
pub const SchemaT = em.import.@"em.core.radio/SchemaT";

const FirstAppR = struct {
    data: Resource.Desc(i16, .RW),
};

pub const Schema = em__U.Generate("Schema", SchemaT, SchemaT.Params{ .ResT = FirstAppR });


//->> zigem publish #|1f09ebf20976606358bf977d3560645fad6ea7cd9f38d6d2f1578ed6823cba5e|#

//->> zigem publish -- end of generated code
