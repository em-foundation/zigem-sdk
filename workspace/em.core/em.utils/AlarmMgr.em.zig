pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    AlarmOF: em.Factory(Alarm),
    WakeupTimer: em.Proxy(WakeupTimerI),
};
pub const x_WakeupTimer = em__C.WakeupTimer;

pub const EpochTime = em.import2.@"em.utils/EpochTime";
pub const FiberMgr = em.import2.@"em.utils/FiberMgr";
pub const WakeupTimerI = em.import2.@"em.hal/WakeupTimerI";

pub const Obj = em.Obj(Alarm);

pub const Alarm = struct {
    _fiber: FiberMgr.Obj,
    _thresh: u32 = 0, // time of alarm
    _ticks: u32 = 0, // ticks remaining until alarm (0 == alarm inactive)
    pub fn cancel(self: *Alarm) void {
        Alarm_cancel(self);
    }
    pub fn isActive(self: *Alarm) bool {
        Alarm_isActive(self);
    }
    pub fn wakeup(self: *Alarm, secs256: u32) void {
        Alarm_wakeup(self, secs256);
    }
    pub fn wakeupAt(self: *Alarm, secs256: u32) void {
        Alarm_wakeupAt(self, secs256);
    }
};

// -------- META --------

pub fn createH(fiber: FiberMgr.Obj) Obj {
    const alarm = em__C.AlarmOF.createH(.{ ._fiber = fiber });
    return alarm;
}

// -------- TARG --------

const WakeupTimer = em__C.WakeupTimer.get();

var cur_alarm: ?*Alarm = null;

fn findNextAlarm(delta_ticks: u32) void {
    WakeupTimer.disable();
    const alarm_tab = em__C.AlarmOF.items();
    var nxt_alarm: ?*Alarm = null;
    var max_ticks = ~@as(u32, 0); // largest u32
    for (0..alarm_tab.len) |idx| {
        var a = &alarm_tab[idx];
        a._ticks -|= delta_ticks;
        if (a._ticks > 0 and a._ticks < max_ticks) {
            nxt_alarm = a;
            max_ticks = a._ticks;
        }
    }
    cur_alarm = nxt_alarm;
    if (cur_alarm != null) {
        WakeupTimer.enable(cur_alarm.?._thresh, &wakeupHandler);
    }
}

fn wakeupHandler(_: WakeupTimerI.HandlerArg) void {
    const alarm_tab = em__C.AlarmOF.items();
    const thresh: u32 = cur_alarm.?._thresh;
    for (0..alarm_tab.len) |idx| {
        var a = &alarm_tab[idx];
        if (a._ticks > 0 and thresh == a._thresh) {
            a._ticks = 0;
            a._fiber.post(); // ring the alarm
        }
    }
    findNextAlarm(cur_alarm.?._ticks);
}

pub fn Alarm_cancel(alarm: *Alarm) void {
    alarm._ticks = 0;
    findNextAlarm(0);
}

pub fn Alarm_isActive(alarm: *Alarm) bool {
    return alarm.ticks != 0;
}

fn Alarm_setup(alarm: *Alarm, ticks: u32) void {
    alarm._thresh = WakeupTimer.ticksToThresh(ticks);
    alarm._ticks = ticks;
    findNextAlarm(0);
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
    Alarm_setup(alarm, ticks - (et_ticks % ticks));
}
