pub const em = @import("../../.gen/em.zig");
pub const em__U = em.Module(@This(), .{
    .inherits = em.import.@"em.hal/IdleI",
});
pub const em__C = em__U.Config(EM__CONFIG);

pub const Debug = em.import.@"em.lang/Debug";
pub const Hapi = em.import.@"ti.mcu.cc23xx/Hapi";

pub const EM__CONFIG = struct {
    sleep_enter_fxn_tab: em.Param(CallbackTab),
    sleep_leave_fxn_tab: em.Param(CallbackTab),
};

pub const SleepEvent = struct {};
pub const Callback = em.CB(SleepEvent);
pub const CallbackFxn = em.Func(Callback);
pub const CallbackTab = em.Table(CallbackFxn);

pub const EM__HOST = struct {
    //
    var sleep_enter_cb_tab = CallbackTab{};
    var sleep_leave_cb_tab = CallbackTab{};

    pub fn em__constructH() void {
        em__C.sleep_enter_fxn_tab.set(sleep_enter_cb_tab);
        em__C.sleep_leave_fxn_tab.set(sleep_leave_cb_tab);
    }

    pub fn addSleepEnterCbH(cb: CallbackFxn) void {
        sleep_enter_cb_tab.add(cb);
    }

    pub fn addSleepLeaveCbH(cb: CallbackFxn) void {
        sleep_leave_cb_tab.add(cb);
    }

    pub fn setWaitOnly(_: bool) void {} // TODO why????
};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    const sleep_enter_fxn_tab = em__C.sleep_enter_fxn_tab.unwrap();
    const sleep_leave_fxn_tab = em__C.sleep_leave_fxn_tab.unwrap();

    var wait_only: bool = false;

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
            const cb = fxn.unwrap();
            cb(SleepEvent{});
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
            const cb = fxn.unwrap();
            cb(SleepEvent{});
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
        if (wait_only) {
            doWait();
        } else {
            doSleep();
        }
    }

    pub fn setWaitOnly(flag: bool) void {
        wait_only = flag;
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
};
