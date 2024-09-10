pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{
    .inherits = em.import.@"em.hal/IdleI",
});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    sleep_enter_fxn_tab: em.Table(SleepCbFxn, .RO),
    sleep_leave_fxn_tab: em.Table(SleepCbFxn, .RO),
};

pub const Debug = em.import.@"em.lang/Debug";
pub const Hapi = em.import.@"ti.mcu.cc23xx/Hapi";

pub const SleepCbFxn = em.Fxn(SleepCbArg);
pub const SleepCbArg = struct {};
pub const CallbackTab = em.Table(SleepCbFxn, .RO);

pub const EM_META = struct {
    //
    var sleep_enter_cb_tab = em__C.sleep_enter_fxn_tab;
    var sleep_leave_cb_tab = em__C.sleep_leave_fxn_tab;

    pub fn addSleepEnterCbH(cb: SleepCbFxn) void {
        sleep_enter_cb_tab.add(cb);
    }

    pub fn addSleepLeaveCbH(cb: SleepCbFxn) void {
        sleep_leave_cb_tab.add(cb);
    }

    pub fn setWaitOnly(_: bool) void {} // TODO why????
};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    const sleep_enter_fxn_tab = em__C.sleep_enter_fxn_tab;
    const sleep_leave_fxn_tab = em__C.sleep_leave_fxn_tab;

    var wait_only: u8 = 0;

    pub fn em__startup() void {
        em.@"%%[b+]"();
        // const tmp = reg(hal.PMCTL_BASE + hal.PMCTL_O_VDDRCTL).* & hal.PMCTL_VDDRCTL_SELECT; // LDO
        // reg(hal.PMCTL_BASE + hal.PMCTL_O_VDDRCTL).* = tmp | hal.PMCTL_VDDRCTL_SELECT_DCDC;
        // reg(hal.EVTULL_BASE + hal.EVTULL_O_WKUPMASK).* = hal.EVTULL_WKUPMASK_AON_RTC_COMB | hal.EVTULL_WKUPMASK_AON_IOC_COMB;
        reg(hal.PMCTL_BASE + hal.PMCTL_O_VDDRCTL).* = hal.PMCTL_VDDRCTL_SELECT; // LDO
        reg(hal.EVTULL_BASE + hal.EVTULL_O_WKUPMASK).* = hal.EVTULL_WKUPMASK_AON_RTC_COMB | hal.EVTULL_WKUPMASK_AON_IOC_COMB;
    }

    fn doSleep() void {
        for (sleep_enter_fxn_tab) |fxn| {
            fxn.?(.{});
        }
        em.@"%%[b:]"(1);
        em.@"%%[b-]"();
        Debug.reset();
        reg(hal.CKMD_BASE + hal.CKMD_O_LDOCTL).* = 0x0;
        set_PRIMASK(1);
        Hapi.enterStandby(0);
        Debug.startup();
        em.@"%%[b+]"();
        for (sleep_leave_fxn_tab) |fxn| {
            fxn.?(.{});
        }
        set_PRIMASK(0);
    }

    fn doWait() void {
        em.@"%%[b:]"(0);
        em.@"%%[b-]"();
        set_PRIMASK(1);
        asm volatile ("wfi");
        em.@"%%[b+]"();
        set_PRIMASK(0);
    }

    pub fn exec() void {
        if (wait_only > 0) {
            doWait();
        } else {
            doSleep();
        }
    }

    pub fn pause() void {
        doWait();
    }

    fn set_PRIMASK(m: u32) void {
        asm volatile ("msr primask, %[m]"
            :
            : [m] "r" (m),
            : "memory"
        );
    }

    pub fn waitOnly(comptime op: enum { CLR, SET }) void {
        switch (op) {
            .CLR => wait_only -= 1,
            .SET => wait_only += 1,
        }
    }

    pub fn wakeup() void {
        // TODO
    }
};
