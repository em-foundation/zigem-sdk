pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const DurationMs = struct {
    min: u16 = 100,
    max: u16 = 4000,
};

pub const OnPressedCbFxn = em.Fxn(OnPressedCbArg);
pub const OnPressedCbArg = struct {};

pub const EM__TARG = struct {
    isPressed: fn () bool,
    onPressed: fn (cb: OnPressedCbFxn, dur: DurationMs) void,
};

//#region zigem

//->> zigem publish #|d46018d836c0692c1854d1acf230d714561f9bce6b62defa43a3c81ccb19d570|#

pub fn isPressed() bool {
    // TODO
    return em.std.mem.zeroes(bool);
}

pub fn onPressed(cb: OnPressedCbFxn, dur: DurationMs) void {
    // TODO
    _ = cb;
    _ = dur;
    return em.std.mem.zeroes(void);
}

const em__Self = @This();

pub const EM__SPEC = struct {
    isPressed: *const @TypeOf(em__Self.isPressed) = &em__Self.isPressed,
    onPressed: *const @TypeOf(em__Self.onPressed) = &em__Self.onPressed,
};

//->> zigem publish -- end of generated code

//#endregion zigem
