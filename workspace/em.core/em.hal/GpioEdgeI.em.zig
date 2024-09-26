pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{ .inherits = GpioI });

pub const GpioI = em.import.@"em.hal/GpioI";

pub const HandlerFxn = em.Fxn(HandlerArg);
pub const HandlerArg = struct {};

pub const EM__SPEC = struct {
    // GpioI
    clear: *const @TypeOf(GpioI.EM__TARG.clear) = &GpioI.EM__TARG.clear,
    functionSelect: *const @TypeOf(GpioI.EM__TARG.functionSelect) = &GpioI.EM__TARG.functionSelect,
    get: *const @TypeOf(GpioI.EM__TARG.get) = &GpioI.EM__TARG.get,
    isInput: *const @TypeOf(GpioI.EM__TARG.isInput) = &GpioI.EM__TARG.isInput,
    isOutput: *const @TypeOf(GpioI.EM__TARG.isOutput) = &GpioI.EM__TARG.isOutput,
    makeInput: *const @TypeOf(GpioI.EM__TARG.makeInput) = &GpioI.EM__TARG.makeInput,
    makeOutput: *const @TypeOf(GpioI.EM__TARG.makeOutput) = &GpioI.EM__TARG.makeOutput,
    pinId: *const @TypeOf(GpioI.EM__TARG.pinId) = &GpioI.EM__TARG.pinId,
    reset: *const @TypeOf(GpioI.EM__TARG.reset) = &GpioI.EM__TARG.reset,
    set: *const @TypeOf(GpioI.EM__TARG.set) = &GpioI.EM__TARG.set,
    setInternalPullup: *const @TypeOf(GpioI.EM__TARG.setInternalPullup) = &GpioI.EM__TARG.setInternalPullup,
    toggle: *const @TypeOf(GpioI.EM__TARG.toggle) = &GpioI.EM__TARG.toggle,
    //
    setDetectHandlerH: *const @TypeOf(EM__META.setDetectHandlerH) = &EM__META.setDetectHandlerH,
    clearDetect: *const @TypeOf(EM__TARG.clearDetect) = &EM__TARG.clearDetect,
    disableDetect: *const @TypeOf(EM__TARG.disableDetect) = &EM__TARG.disableDetect,
    enableDetect: *const @TypeOf(EM__TARG.enableDetect) = &EM__TARG.enableDetect,
    setDetectFallingEdge: *const @TypeOf(EM__TARG.setDetectFallingEdge) = &EM__TARG.setDetectFallingEdge,
    setDetectRisingEdge: *const @TypeOf(EM__TARG.setDetectRisingEdge) = &EM__TARG.setDetectRisingEdge,
};

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
