pub const em = @import("../../zigem/gen/em.zig");
pub const em__U = em.interface(@This(), .{});

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
