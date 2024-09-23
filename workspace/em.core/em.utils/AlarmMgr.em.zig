pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    AlarmOF: em.Factory(Alarm),
    WakeupTimer: em.Proxy(em.import.@"em.hal/WakeupTimerI"),
};

pub const EpochTime = em.import.@"em.utils/EpochTime";
pub const FiberMgr = em.import.@"em.utils/FiberMgr";

pub const Obj = em.Obj(Alarm);

pub const Alarm = struct {
    const Self = @This();
    _fiber: FiberMgr.Obj,
    _thresh: u32 = 0, // time of alarm
    _dticks: u32 = 0, // delta ticks until alarm (0 == alarm inactive)
    _idx: u8,
    pub fn active(self: *Self) bool {
        em__U.scope().Alarm_active(self);
    }
    pub fn cancel(self: *Self) void {
        em__U.scope().Alarm_cancel(self);
    }
    pub fn wakeup(self: *Self, secs256: u32) void {
        em__U.scope().Alarm_wakeup(self, secs256);
    }
    pub fn wakeupAt(self: *Self, secs256: u32) void {
        em__U.scope().Alarm_wakeupAt(self, secs256);
    }
};

pub const EM__META = struct {
    //
    pub const WakeupTimer = em__C.WakeupTimer;

    var cur_idx: u8 = 0;

    pub fn createH(fiber: FiberMgr.Obj) Obj {
        cur_idx += 1;
        const alarm = em__C.AlarmOF.createH(.{ ._fiber = fiber, ._idx = cur_idx });
        return alarm;
    }
};

pub const EM__TARG = struct {
    //
    const WakeupTimer = em__C.WakeupTimer.scope();

    var cur_alarm: ?*Alarm = null;

    fn dispatch(delta: u32) void {
        WakeupTimer.disable();
        const alarm_tab = em__C.AlarmOF;
        var nxt_alarm: ?*Alarm = null;
        var max_ticks = ~@as(u32, 0); // largest u32
        for (0..alarm_tab.len) |idx| {
            const a = &alarm_tab[idx];
            if (a._dticks == 0) continue; // inactive
            a._dticks -|= delta;
            if (a._dticks == 0) {
                a._fiber.post(); // ring the alarm
                continue; // inactive
            }
            if (a._dticks < max_ticks) {
                nxt_alarm = a;
                max_ticks = a._dticks;
            }
        }
        cur_alarm = nxt_alarm;
        if (cur_alarm) |ca| {
            WakeupTimer.enable(ca._thresh, &wakeupHandler);
        }
    }

    fn wakeupHandler(_: WakeupTimer.HandlerArg) void {
        dispatch(cur_alarm.?._dticks);
    }

    pub fn Alarm_cancel(alarm: *Alarm) void {
        alarm._dticks = 0;
        dispatch(0);
    }

    pub fn Alarm_isActive(alarm: *Alarm) bool {
        return alarm.ticks != 0;
    }

    fn Alarm_setup(alarm: *Alarm, ticks: u32) void {
        alarm._thresh = WakeupTimer.ticksToThresh(ticks);
        alarm._dticks = ticks;
        dispatch(0);
    }

    pub fn Alarm_wakeup(alarm: *Alarm, secs256: u32) void {
        const ticks = WakeupTimer.secs256ToTicks(secs256);
        Alarm_setup(alarm, ticks);
    }

    pub fn Alarm_wakeupAt(alarm: *Alarm, secs256: u32) void {
        var et_subs: u32 = undefined;
        const et_secs = EpochTime.getCurrent(&et_subs);
        const et_ticks = WakeupTimer.timeToTicks(et_secs, et_subs);
        const ticks = WakeupTimer.secs256ToTicks(secs256);
        const rem = et_ticks % ticks;
        Alarm_setup(alarm, ticks - rem);
    }
};
