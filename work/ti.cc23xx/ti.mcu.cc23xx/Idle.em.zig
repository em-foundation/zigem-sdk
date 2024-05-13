pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{
    .inherits = em.Import.@"em.hal/IdleI",
});

pub const EM__HOST = struct {};

pub const EM__TARG = struct {};

const hal = em.hal;
const reg = em.reg;

pub fn em__startup() void {
    em.@"%%[b+]"();
    reg(hal.PMCTL_BASE + hal.PMCTL_O_VDDRCTL).* = hal.PMCTL_VDDRCTL_SELECT; // LDO
    reg(hal.EVTULL_BASE + hal.EVTULL_O_WKUPMASK).* = hal.EVTULL_WKUPMASK_AON_RTC_COMB | hal.EVTULL_WKUPMASK_AON_IOC_COMB;
}

fn doWait() void {
    if (em.hosted) return;
    em.@"%%[b:]"(0);
    em.@"%%[b-]"();
    set_PRIMASK(1);
    asm volatile ("wfi");
    em.@"%%[b+]"();
    set_PRIMASK(0);
}

pub fn exec() void {
    doWait();
}

fn set_PRIMASK(m: u32) void {
    asm volatile ("msr primask, %[m]"
        :
        : [m] "r" (m),
        : "memory"
    );
}

pub fn wakeup() void {
    // TODO
}
