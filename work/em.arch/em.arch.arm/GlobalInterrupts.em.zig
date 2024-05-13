pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{
    .inherits = em.Import.@"em.hal/GlobalInterruptsI",
});

pub const EM__HOST = struct {};

pub const EM__TARG = struct {};

pub fn disable() u32 {
    const key = get_PRIMASK();
    set_PRIMASK(1);
    return key;
}

pub fn enable() void {
    set_PRIMASK(0);
}

pub fn restore(key: u32) void {
    set_PRIMASK(key);
}

fn get_PRIMASK() u32 {
    if (em.hosted) return 0;
    const key: u32 = 0;
    asm volatile (
        \\mrs %[key], primask        
        :
        : [key] "r" (key),
        : "memory"
    );
    return key;
}

fn set_PRIMASK(m: u32) void {
    if (em.hosted) return;
    asm volatile ("msr primask, %[m]"
        :
        : [m] "r" (m),
        : "memory"
    );
}
