pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    app_ticker: em.Param(TickerMgr.Obj),
    sys_ticker: em.Param(TickerMgr.Obj),
    print_ticker: em.Param(TickerMgr.Obj),
};

pub const AppBut = em.import.@"em__distro/BoardC".AppBut;
pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const EpochTime = em.import.@"em.utils/EpochTime";
pub const FiberMgr = em.import.@"em.utils/FiberMgr";
pub const TickerMgr = em.import.@"em.utils/TickerMgr";
pub const SysLed = em.import.@"em__distro/BoardC".SysLed;

pub const EM__META = struct {
    pub fn em__constructH() void {
        em__C.app_ticker.set(TickerMgr.createH());
        em__C.sys_ticker.set(TickerMgr.createH());
        em__C.print_ticker.set(TickerMgr.createH());
    }
};

pub const EM__TARG = struct {
    //
    const app_ticker = em__C.app_ticker;
    const sys_ticker = em__C.sys_ticker;
    const print_ticker = em__C.print_ticker;

    const max_sys_led_ticks: u32 = 384; // 1.5s
    const max_app_led_ticks: u32 = 512; // 2s
    const print_ticks: u32 = 1280; // 5s
    const min_press_time = 10; // 10ms
    const max_press_time = 2000; // 2s
    var divided_by: u32 = 1;

    var sys_count: u32 = 0;
    var app_count: u32 = 0;
    var last_app_count: u32 = 0;
    var last_sys_count: u32 = 0;
    var print_count: u32 = 0;

    pub fn em__run() void {
        em.print("Starting at rate {}x\n", .{divided_by});
        printStatus();
        AppBut.onPressed(onButtonPressed, .{ .min = min_press_time, .max = max_press_time });
        app_ticker.start(max_app_led_ticks, &appTickCb);
        sys_ticker.start(max_sys_led_ticks, &sysTickCb);
        print_ticker.start(print_ticks, &printTickCb);
        FiberMgr.run();
    }

    fn printStatus() void {
        em.print("... delta print time should be ~{d}s\n", .{print_ticks / 256});
        em.print("... delta_app_count should be {d}..{d}\n", .{ divided_by * print_ticks / max_app_led_ticks, (divided_by * print_ticks / max_app_led_ticks) + 1 });
        em.print("... delta_sys_count should be {d}..{d}\n", .{ divided_by * print_ticks / max_sys_led_ticks, (divided_by * print_ticks / max_sys_led_ticks) + 1 });
    }

    fn appTickCb(_: TickerMgr.CallbackArg) void {
        app_count += 1;
        AppLed.wink(10);
    }

    fn sysTickCb(_: TickerMgr.CallbackArg) void {
        sys_count += 1;
        SysLed.wink(10);
    }

    fn printTickCb(_: TickerMgr.CallbackArg) void {
        print_count += 1;
        var sub_seconds: u32 = 0;
        const seconds = EpochTime.getRawTime(&sub_seconds);
        const ms = EpochTime.msecsFromSubs(sub_seconds);
        const delta_app_count = app_count - last_app_count;
        const delta_sys_count = sys_count - last_sys_count;
        const min_delta_app_count = divided_by * print_ticks / max_app_led_ticks;
        const min_delta_sys_count = divided_by * print_ticks / max_sys_led_ticks;
        const delta_app_err = if (delta_app_count < min_delta_app_count or delta_app_count > min_delta_app_count + 1) "*" else "";
        const delta_sys_err = if (delta_sys_count < min_delta_sys_count or delta_sys_count > min_delta_sys_count + 1) "*" else "";
        em.print("{d}.{d:0>3}:  Hello World:  rate={d}x  delta_app_count={d}{s}  delta_sys_count={d}{s}\n", .{ seconds, ms, divided_by, delta_app_count, delta_app_err, delta_sys_count, delta_sys_err });
        if (divided_by > 0 and last_sys_count > 0 and last_sys_count == sys_count) {
            em.print("Sys ticker count did not increment\n", .{});
            em.halt();
        }
        if (divided_by > 0 and last_app_count > 0 and last_app_count == app_count) {
            em.print("App ticker count did not increment\n", .{});
            em.halt();
        }
        last_app_count = app_count;
        last_sys_count = sys_count;
    }

    pub fn onButtonPressed(_: AppBut.OnPressedCbArg) void {
        if (AppBut.isPressed()) {
            // a long press (press time > max_press_time)
            em.print("Long button press: Stopping app/sys tickers\n", .{});
            divided_by = 0;
            app_ticker.stop();
            sys_ticker.stop();
            last_app_count = 0;
            last_sys_count = 0;
        } else {
            // a short press (min_press_time < press time < max_press_time)
            divided_by = if (divided_by >= 8 or divided_by < 1) 1 else divided_by * 2;
            em.print("Short button press: Setting rate to {}x\n", .{divided_by});
            printStatus();
            app_ticker.start(max_app_led_ticks / divided_by, &appTickCb);
            sys_ticker.start(max_sys_led_ticks / divided_by, &sysTickCb);
        }
    }
};
