pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const TimeTypes = em.import.@"em.utils/TimeTypes";

pub const HandlerFxn = em.Fxn(HandlerArg);
pub const HandlerArg = struct {};

pub const Secs24p8 = TimeTypes.Secs24p8;
pub const Thresh = u32;

pub const EM__TARG = struct {
    disable: fn () void,
    enable: fn (thresh: Thresh, handler: HandlerFxn) void,
    secsAligned: fn (secs: Secs24p8) Secs24p8,
    secsToThresh: fn (secs: Secs24p8) Thresh,
};


//->> zigem publish #|491cb234436603cedb7b73a071fefa555e5e1b6f472e141f8bd62b3bc8dde053|#

pub fn disable () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn enable (thresh: Thresh, handler: HandlerFxn) void {
    // TODO
    _ = thresh;
    _ = handler;
    return em.std.mem.zeroes(void);
}

pub fn secsAligned (secs: Secs24p8) Secs24p8 {
    // TODO
    _ = secs;
    return em.std.mem.zeroes(Secs24p8);
}

pub fn secsToThresh (secs: Secs24p8) Thresh {
    // TODO
    _ = secs;
    return em.std.mem.zeroes(Thresh);
}

const em__Self = @This();

pub const EM__SPEC = struct {
    disable: *const @TypeOf(em__Self.disable) = &em__Self.disable,
    enable: *const @TypeOf(em__Self.enable) = &em__Self.enable,
    secsAligned: *const @TypeOf(em__Self.secsAligned) = &em__Self.secsAligned,
    secsToThresh: *const @TypeOf(em__Self.secsToThresh) = &em__Self.secsToThresh,
};

//->> zigem publish -- end of generated code
