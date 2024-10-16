pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__SPEC = struct {
    off: *const @TypeOf(off) = &off,
    on: *const @TypeOf(on) = &on,
    toggle: *const @TypeOf(toggle) = &toggle,
};

pub fn off() void {
    return;
}

pub fn on() void {
    return;
}

pub fn toggle() void {
    return;
}

//->> zigem publish #|8e656bdabb1bbc887135f1c632a142218f77678dc4a0a941e3f60b275a79b81d|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted
