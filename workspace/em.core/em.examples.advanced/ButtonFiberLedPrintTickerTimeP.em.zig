pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    appTicker: em.Param(TickerMgr.Obj),
    sysTicker: em.Param(TickerMgr.Obj),
    printTicker: em.Param(TickerMgr.Obj),
};

pub const AppBut = em.import.@"em__distro/BoardC".AppBut;
pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const EpochTime = em.import.@"em.utils/EpochTime";
pub const FiberMgr = em.import.@"em.utils/FiberMgr";
pub const TickerMgr = em.import.@"em.utils/TickerMgr";
pub const SysLed = em.import.@"em__distro/BoardC".SysLed;

pub const EM__META = struct {
    pub fn em__constructH() void {
        em__C.appTicker.set(TickerMgr.createH());
        em__C.sysTicker.set(TickerMgr.createH());
        em__C.printTicker.set(TickerMgr.createH());
    }
};

pub const EM__TARG = struct {
    //
    const appTicker = em__C.appTicker;
    const sysTicker = em__C.sysTicker;
    const printTicker = em__C.printTicker;

    const maxSysLedTicks: u32 = 384; // 1.5s
    const maxAppLedTicks: u32 = 512; // 2s
    const printTicks: u32 = 1280; // 5s
    const minPressTime = 10; // 10ms
    const maxPressTime = 2000; // 2s
    var dividedBy: u32 = 1;

    var sysCount: u32 = 0;
    var appCount: u32 = 0;
    var lastAppCount: u32 = 0;
    var lastSysCount: u32 = 0;
    var printCount: u32 = 0;

    pub fn em__run() void {
        em.print("Starting at rate {}x\n", .{dividedBy});
        em.print("... delta print time should be {}\n", .{printTicks / 256});
        em.print("... deltaAppCount should be {} - {}\n", .{ dividedBy * printTicks / maxAppLedTicks, (dividedBy * printTicks / maxAppLedTicks) + 1 });
        em.print("... deltaSysCount should be {} - {}\n", .{ dividedBy * printTicks / maxSysLedTicks, (dividedBy * printTicks / maxSysLedTicks) + 1 });
        AppBut.onPressed(onButtonPressed, .{ .min = minPressTime, .max = maxPressTime });
        appTicker.start(maxAppLedTicks, &appTickCb);
        sysTicker.start(maxSysLedTicks, &sysTickCb);
        printTicker.start(printTicks, &printTickCb);
        FiberMgr.run();
    }

    fn appTickCb(_: TickerMgr.CallbackArg) void {
        appCount += 1;
        AppLed.wink(10);
    }

    fn sysTickCb(_: TickerMgr.CallbackArg) void {
        sysCount += 1;
        SysLed.wink(10);
    }

    fn printTickCb(_: TickerMgr.CallbackArg) void {
        printCount += 1;
        var subSeconds: u32 = 0;
        const seconds = EpochTime.getCurrent(&subSeconds);
        const deltaAppCount = appCount - lastAppCount;
        const deltaSysCount = sysCount - lastSysCount;
        em.print("{}: Hello World: Rate={}x deltaAppCount={} deltaSysCount={}\n", .{ seconds, dividedBy, deltaAppCount, deltaSysCount });
        if (dividedBy > 0 and lastSysCount > 0 and lastSysCount == sysCount) {
            em.print("Sys ticker count did not increment\n", .{});
            em.halt();
        }
        if (dividedBy > 0 and lastAppCount > 0 and lastAppCount == appCount) {
            em.print("App ticker count did not increment\n", .{});
            em.halt();
        }
        lastAppCount = appCount;
        lastSysCount = sysCount;
    }

    pub fn onButtonPressed(_: AppBut.OnPressedCbArg) void {
        if (AppBut.isPressed()) {
            // a long press (press time > maxPressTime)
            em.print("Long button press: Stopping app/sys tickers\n", .{});
            dividedBy = 0;
            appTicker.stop();
            sysTicker.stop();
            lastAppCount = 0;
            lastSysCount = 0;
        } else {
            // a short press (minPressTime < press time < maxPressTime)
            dividedBy = if (dividedBy >= 8 or dividedBy < 1) 1 else dividedBy * 2;
            em.print("Short button press: Setting rate to {}x\n", .{dividedBy});
            em.print("... deltaAppCount should be {} - {}\n", .{ dividedBy * printTicks / maxAppLedTicks, (dividedBy * printTicks / maxAppLedTicks) + 1 });
            em.print("... deltaSysCount should be {} - {}\n", .{ dividedBy * printTicks / maxSysLedTicks, (dividedBy * printTicks / maxSysLedTicks) + 1 });
            appTicker.stop();
            sysTicker.stop();
            lastAppCount = 0;
            lastSysCount = 0;
            appTicker.start(maxAppLedTicks / dividedBy, &appTickCb);
            sysTicker.start(maxSysLedTicks / dividedBy, &sysTickCb);
        }
    }
};
