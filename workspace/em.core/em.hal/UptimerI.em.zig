pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const TimeTypes = em.import.@"em.utils/TimeTypes";

pub const EM__TARG = struct {
    read: fn () TimeTypes.RawTime,
};

//#region zigem

//->> zigem publish #|e62fe37cdc91d4a28079688d2f0ae4c9580333e55b8d28e1d327221944fd6a3d|#

pub fn read() TimeTypes.RawTime {
    // TODO
    return em.std.mem.zeroes(TimeTypes.RawTime);
}

const em__Self = @This();

pub const EM__SPEC = struct {
    read: *const @TypeOf(em__Self.read) = &em__Self.read,
};

//->> zigem publish -- end of generated code

//#endregion zigem
