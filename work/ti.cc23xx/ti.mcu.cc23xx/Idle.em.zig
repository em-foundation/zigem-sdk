pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{
    .inherits = em.Import.@"em.hal/IdleI",
});

pub const Debug = em.Import.@"em.lang/Debug";
pub const Hapi = em.Import.@"ti.mcu.cc23xx/Hapi";
pub const Uart = em.Import.@"ti.mcu.cc23xx/ConsoleUart0";

pub const SleepEvent = struct {};
pub const Callback = em.Func(em.CB(SleepEvent));
pub const CallbackTab = em.Table(Callback);

//pub const c_sleep_enter_cb_tab = em__unit.config("sleep_enter_cb_tab", CallbackTab);
//pub const c_sleep_leave_cb_tab = em__unit.config("sleep_leave_cb_tab", CallbackTab);

pub const EM__HOST = struct {
    //
    var sleep_enter_cb_tab = CallbackTab{};
    var sleep_leave_cb_tab = CallbackTab{};

    pub fn em__constructH() void {
        //c_sleep_enter_cb_tab.set(sleep_enter_cb_tab);
        //c_sleep_leave_cb_tab.set(sleep_leave_cb_tab);
    }

    pub fn addSleepEnterCbH(cb: Callback) void {
        sleep_enter_cb_tab.add(cb);
    }

    pub fn addSleepLeaveCbH(cb: Callback) void {
        sleep_leave_cb_tab.add(cb);
    }

    pub fn setWaitOnly(_: bool) void {} // TODO why????
};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    //    const sleep_enter_cb_tab = c_sleep_enter_cb_tab.unwrap();
    //    const sleep_leave_cb_tab = c_sleep_leave_cb_tab.unwrap();

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
        //        for (sleep_enter_cb_tab) |cb| cb();
        Uart.sleepEnter();
        em.@"%%[b:]"(1);
        em.@"%%[b-]"();
        Debug.reset();
        reg(hal.CKMD_BASE + hal.CKMD_O_LDOCTL).* = 0x0;
        set_PRIMASK(1);
        Hapi.enterStandby(0);
        Debug.startup();
        em.@"%%[b+]"();
        Uart.sleepLeave();
        //        for (sleep_leave_cb_tab) |cb| cb();
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
