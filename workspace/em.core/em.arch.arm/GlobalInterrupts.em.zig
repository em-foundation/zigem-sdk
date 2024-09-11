pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{
    .inherits = em.import.@"em.hal/GlobalInterruptsI",
});

pub const EM_META = struct {
    //
};

pub const EM__TARG = struct {
    //
    pub fn disable() u32 {
        const key = get_PRIMASK();
        asm volatile ("cpsid i" ::: "memory");
        // set_PRIMASK(1);
        return key;
    }

    pub fn enable() void {
        asm volatile ("cpsie i" ::: "memory");
    }

    pub fn isEnabled() bool {
        return get_PRIMASK() == 0;
    }

    pub fn restore(key: u32) void {
        if (key == 0) enable();
    }

    pub fn get_PRIMASK() u32 {
        return asm volatile (
            \\mrs %[ret], primask        
            : [ret] "={r0}" (-> u32),
        );
    }
};
