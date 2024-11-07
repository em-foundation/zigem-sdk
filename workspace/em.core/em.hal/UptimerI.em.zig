pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const TimeTypes = em.import.@"em.utils/TimeTypes";

pub const EM__TARG = struct {
    read: fn () TimeTypes.RawTime,
};


//->> zigem publish #|7601f49ca0a97533e1222b2d7013693459f211635b3333610e1e5e142c722cf1|#

pub fn read () TimeTypes.RawTime {
    // TODO
    return em.std.mem.zeroes(TimeTypes.RawTime);
}

const em__Self = @This();

pub const EM__SPEC = struct {
    read: *const @TypeOf(em__Self.read) = &em__Self.read,
};

//->> zigem publish -- end of generated code
