pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const TimeTypes = em.import.@"em.utils/TimeTypes";

pub const HandlerFxn = em.Fxn(HandlerArg);
pub const HandlerArg = struct {};

pub const Secs24p8 = TimeTypes.Secs24p8;
pub const Thresh = u32;

pub const EM__SPEC = struct {
    disable: *const @TypeOf(disable) = &disable,
    enable: *const @TypeOf(enable) = &enable,
    secsAligned: *const @TypeOf(secsAligned) = &secsAligned,
    secsToThresh: *const @TypeOf(secsToThresh) = &secsToThresh,
};

pub fn disable() void {
    return;
}

pub fn enable(thresh: Thresh, handler: HandlerFxn) void {
    _ = thresh;
    _ = handler;
    return;
}

pub fn secsAligned(secs: Secs24p8) Secs24p8 {
    _ = secs;
    return TimeTypes.Secs24p8_ZERO();
}

pub fn secsToThresh(secs: Secs24p8) Thresh {
    _ = secs;
    return 0;
}
