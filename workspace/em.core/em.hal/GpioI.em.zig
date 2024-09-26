pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__SPEC = struct {
    clear: *const @TypeOf(EM__TARG.clear) = &EM__TARG.clear,
    functionSelect: *const @TypeOf(EM__TARG.functionSelect) = &EM__TARG.functionSelect,
    get: *const @TypeOf(EM__TARG.get) = &EM__TARG.get,
    isInput: *const @TypeOf(EM__TARG.isInput) = &EM__TARG.isInput,
    isOutput: *const @TypeOf(EM__TARG.isOutput) = &EM__TARG.isOutput,
    makeInput: *const @TypeOf(EM__TARG.makeInput) = &EM__TARG.makeInput,
    makeOutput: *const @TypeOf(EM__TARG.makeOutput) = &EM__TARG.makeOutput,
    pinId: *const @TypeOf(EM__TARG.pinId) = &EM__TARG.pinId,
    reset: *const @TypeOf(EM__TARG.reset) = &EM__TARG.reset,
    set: *const @TypeOf(EM__TARG.set) = &EM__TARG.set,
    setInternalPullup: *const @TypeOf(EM__TARG.setInternalPullup) = &EM__TARG.setInternalPullup,
    toggle: *const @TypeOf(EM__TARG.toggle) = &EM__TARG.toggle,
};

pub const EM__TARG = struct {
    pub fn clear() void {
        return;
    }
    pub fn functionSelect(select: u8) void {
        _ = select;
        return;
    }
    pub fn get() bool {
        return false;
    }
    pub fn isInput() bool {
        return false;
    }
    pub fn isOutput() bool {
        return false;
    }
    pub fn makeInput() void {
        return;
    }
    pub fn makeOutput() void {
        return;
    }
    pub fn pinId() i16 {
        return -1;
    }
    pub fn reset() void {
        return;
    }
    pub fn set() void {
        return;
    }
    pub fn setInternalPullup(enable: bool) void {
        _ = enable;
        return;
    }
    pub fn toggle() void {
        return;
    }
};
