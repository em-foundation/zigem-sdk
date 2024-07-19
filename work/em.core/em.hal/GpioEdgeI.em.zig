pub const em = @import("../../.gen/em.zig");
pub const em__U = em.interface(@This(), .{
    .inherits = em.import.@"em.hal/GpioI",
});

pub const Handler = em.Fxn(struct {});

pub fn setDetectHandlerH(h: Handler) void {
    _ = h;
    return;
}

pub fn clearDetect() void {
    return;
}

pub fn disableDetect() void {
    return;
}

pub fn enableDetect() void {
    return;
}

pub fn setDetectFallingEdge() void {
    return;
}

pub fn setDetectRisingEdge() void {
    return;
}
