pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{
    .inherits = em.import.@"em.hal/GpioI",
});

pub const HandlerFxn = em.Fxn(HandlerArg);
pub const HandlerArg = struct {};

pub const EM__META = struct {
    pub fn setDetectHandlerH(h: HandlerFxn) void {
        _ = h;
        return;
    }
};

pub const EM__TARG = struct {
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
};
