pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Interface(@This(), .{});

pub const Handler = struct {};

pub fn disable() void {
    return;
}

pub fn enable(thresh: u32, handler: em.CB(Handler)) void {
    _ = thresh;
    _ = handler;
    return;
}

pub fn secs256ToTicks(secs256: u32) u32 {
    _ = secs256;
    return 0;
}

pub fn ticksToThresh(ticks: u32) u32 {
    _ = ticks;
    return 0;
}

pub fn timeToTicks(secs: u32, subs: u32) u32 {
    _ = secs;
    _ = subs;
    return 0;
}
