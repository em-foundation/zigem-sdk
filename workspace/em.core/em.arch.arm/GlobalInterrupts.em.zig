pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{ .inherits = GlobalInterruptsI });

pub const GlobalInterruptsI = em.import.@"em.hal/GlobalInterruptsI";

pub fn disable() u32 {
    if (em.IS_META) return 0;
    const key = get_PRIMASK();
    asm volatile ("cpsid i" ::: "memory");
    return key;
}

pub fn enable() void {
    if (em.IS_META) return;
    asm volatile ("cpsie i" ::: "memory");
}

pub fn isEnabled() bool {
    if (em.IS_META) return false;
    return get_PRIMASK() == 0;
}

pub fn restore(key: u32) void {
    if (em.IS_META) return;
    if (key == 0) enable();
}

pub fn get_PRIMASK() u32 {
    if (em.IS_META) return 0;
    return asm volatile (
        \\mrs %[ret], primask        
        : [ret] "={r0}" (-> u32),
    );
}
