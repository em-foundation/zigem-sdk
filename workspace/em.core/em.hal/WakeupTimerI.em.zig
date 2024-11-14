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

//#region zigem

//->> zigem publish #|f0c99e989a005fbc6e76c98f35562ac809fdd625261513d71ad0ce7ce2d224b6|#

pub fn disable () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn enable (