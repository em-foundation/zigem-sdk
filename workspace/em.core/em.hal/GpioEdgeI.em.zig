pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This());

pub const HandlerFxn = em.Fxn(HandlerArg);
pub const HandlerArg = struct {};

pub const EM__META = struct {
    setDetectHandlerM: fn (h: HandlerFxn) void,
};

pub const EM__TARG = struct {
    clearDetect: fn () void,
    disableDetect: fn () void,
    getState: fn () bool,
    enableDetect: fn () void,
    setDetectFallingEdge: fn () void,
    setDetectRisingEdge: fn () void,
};

//->> zigem publish #|d0428b25dcecca2b6f68a4b2337c6e1a8f74945d2961ca23ccb9d2fd3003f2cc|#

pub fn setDetectHandlerM (h: HandlerFxn) void {
    // TODO
    _ = h;
    return em.std.mem.zeroes(void);
}

pub fn clearDetect () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn disableDetect () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn getState () bool {
    // TODO
    return em.std.mem.zeroes(bool);
}

pub fn enableDetect () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn setDetectFallingEdge () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn setDetectRisingEdge () void {
    // TODO
    return em.std.mem.zeroes(void);
}

const em__Self = @This();

pub const EM__SPEC = struct {
    setDetectHandlerM: *const @TypeOf(em__Self.setDetectHandlerM) = &em__Self.setDetectHandlerM,
    clearDetect: *const @TypeOf(em__Self.clearDetect) = &em__Self.clearDetect,
    disableDetect: *const @TypeOf(em__Self.disableDetect) = &em__Self.disableDetect,
    getState: *const @TypeOf(em__Self.getState) = &em__Self.getState,
    enableDetect: *const @TypeOf(em__Self.enableDetect) = &em__Self.enableDetect,
    setDetectFallingEdge: *const @TypeOf(em__Self.setDetectFallingEdge) = &em__Self.setDetectFallingEdge,
    setDetectRisingEdge: *const @TypeOf(em__Self.setDetectRisingEdge) = &em__Self.setDetectRisingEdge,
};

//->> zigem publish -- end of generated code
