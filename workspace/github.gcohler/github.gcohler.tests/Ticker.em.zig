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
    var dividedBy: u32 = 1;

    var sysCount: u32 = 0;
    var appCount: u32 = 0;
    var lastAppCount: u32 = 0;
    var lastSysCount: u32 = 0;
    var printCount: u32 = 0;

    pub fn em__run() void {
        AppBut.onPressed(onButtonPressed, .{ .min = 10, .max = 2000 });
        appTicker.start(maxAppLedTicks, &appTickCb);
        sysTicker.start(maxSysLedTicks, &sysTickCb);
        printTicker.start(1024, &printTickCb);
        FiberMgr.run();
    }

    fn appTickCb(_: TickerMgr.CallbackArg) void {
        appCount += 1;
        AppLed.wink(20);
    }

    fn sysTickCb(_: TickerMgr.CallbackArg) void {
        sysCount += 1;
        SysLed.wink(20);
    }

    fn printTickCb(_: TickerMgr.CallbackArg) void {
        printCount += 1;
        var subSeconds: u32 = 0;
        const seconds = EpochTime.getCurrent(&subSeconds);
        em.print("{}: Hello World: Rate={}x app={} sys={}\n", .{ seconds, dividedBy, appCount, sysCount });
        if (dividedBy > 0 and lastSysCount > 0 and lastSysCount == sysCount) {
            em.print("SysLed count did not increment\n", .{});
            em.halt();
        }
        lastAppCount = appCount;
        lastSysCount = sysCount;
    }

    pub fn onButtonPressed(_: AppBut.OnPressedCbArg) void {
        if (AppBut.isPressed()) {
            // a long press (press time > max), back to original
            em.print("Long button press: Resetting\n", .{});
            dividedBy = 0;
            appTicker.stop();
            sysTicker.stop();
            lastAppCount = 0;
            lastSysCount = 0;
        } else {
            // a short press (min < press time < max)
            em.print("Short button press: Rotating\n", .{});
            dividedBy = if (dividedBy >= 8 or dividedBy < 1) 1 else dividedBy * 2;
            appTicker.start(maxAppLedTicks / dividedBy, &appTickCb);
            sysTicker.start(maxSysLedTicks / dividedBy, &sysTickCb);
        }
    }
};
