pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const DurationMs = struct {
    min: u16 = 100,
    max: u16 = 4000,
};

pub const OnPressedCbFxn = em.Fxn(OnPressedCbArg);
pub const OnPressedCbArg = struct {};

pub const EM__SPEC = struct {
    isPressed: *const @TypeOf(EM__TARG.isPressed) = &EM__TARG.isPressed,
    onPressed: *const @TypeOf(EM__TARG.onPressed) = &EM__TARG.onPressed,
};

pub const EM__TARG = struct {
    pub fn isPressed() bool {
        return false;
    }
    pub fn onPressed(cb: OnPressedCbFxn, dur: DurationMs) void {
        _ = cb;
        _ = dur;
    }
};
