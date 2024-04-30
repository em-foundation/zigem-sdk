pub const EM__SPEC = {};

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{
    .inherits = em.Import.@"em.hal/GlobalInterruptsI",
});

pub const EM__HOST = {};

pub const EM__TARG = {};

pub fn disable() u32 {

    //auto key = <uarg_t>(^^__get_PRIMASK()^^)
    //^^__set_PRIMASK(1)^^
    //return key
}

pub fn enable() void {
    //^^__set_PRIMASK(0)^^
}

pub fn restore(key: u32) void {
    _ = key;
    // ^^__set_PRIMASK(key)^^
}
