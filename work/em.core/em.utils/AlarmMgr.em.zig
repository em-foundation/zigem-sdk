pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const EpochTime = em.Import.@"em.utils/EpochTime";
pub const FiberMgr = em.Import.@"em.utils/FiberMgr";

pub const x_WakeupTimer = em__unit.proxy("WakeupTimer", em.Import.@"em.hal/WakeupTimerI");

pub const Alarm = struct {
    const Self = @This();
    _fiber: FiberMgr.Obj,
    _thresh: u32 = 0,
    _ticks: u32 = 0,
    pub fn active(self: *Self) bool {
        em__unit.scope.Alarm_active(self);
    }
    pub fn cancel(self: *Self) void {
        em__unit.scope.Alarm_cancel(self);
    }
    pub fn wakeup(self: *Self, secs256: u32) void {
        em__unit.scope.Alarm_wakeup(self, secs256);
    }
    pub fn wakeupAt(self: *Self, secs256: u32) void {
        em__unit.scope.Alarm_wakeupAt(self, secs256);
    }
};

pub const a_heap = em__unit.array("a_heap", Alarm);

pub const Obj = em.Ref(Alarm);
pub fn @"->"(obj: Obj) ?*Alarm {
    return a_heap.get(obj);
}

pub const EM__HOST = struct {
    //
    pub fn createH(fiber: FiberMgr.Obj) Obj {
        const alarm = a_heap.alloc(.{ ._fiber = fiber });
        return alarm;
    }
};

pub const EM__TARG = struct {
    //
    const WakeupTimer = x_WakeupTimer.unwrap();

    var alarm_tab = a_heap.unwrap();
    var cur_alarm: ?*Alarm = null;

    fn update(delta_ticks: u32) void {
        const thresh: u32 = if (delta_ticks > 0) cur_alarm.?._thresh else 0;
        WakeupTimer.disable();
        var nxt_alarm: ?*Alarm = null;
        var max_ticks = ~@as(u32, 0); // largest u32
        for (0..alarm_tab.len) |idx| {
            var a = &alarm_tab[idx];
            if (a._ticks == 0) continue; // inactive alarm
            a._ticks -= delta_ticks;
            if (a._thresh <= thresh) { // expired alarm
                FiberMgr.@"->"(a._fiber).?.post();
            } else if (a._ticks < max_ticks) {
                nxt_alarm = a;
                max_ticks = a._ticks;
            }
        }
        if (nxt_alarm == null) return; // no active alarms
        cur_alarm = nxt_alarm;
        WakeupTimer.enable(cur_alarm.?._thresh, &wakeupHandler);
    }

    fn wakeupHandler(_: WakeupTimer.Handler) void {
        update(cur_alarm.?._ticks);
    }

    pub fn Alarm_cancel(alarm: *Alarm) void {
        alarm._ticks = 0;
        update(0);
    }

    pub fn Alarm_isActive(alarm: *Alarm) bool {
        return alarm.ticks != 0;
    }

    fn Alarm_setup(alarm: *Alarm, ticks: u32) void {
        alarm._thresh = WakeupTimer.ticksToThresh(ticks);
        alarm._ticks = ticks;
        update(0);
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
};

//
//def Alarm.active()
//    return this.ticks != 0
//end
//
//def Alarm.cancel()
//    this.ticks = 0
//    update(0)
//end
//
//def Alarm.id()
//    return <uint8>(this - &alarmTab[0])
//end
//
//def Alarm.setup(ticks)
//#    %%[>ticks]
//#    %%[a+]
//    this.thresh = WakeupTimer.ticksToThresh(ticks)
//#    %%[a-]
//#    %%[>this.id()]
//#    %%[>this.thresh]
//    this.ticks = ticks
//    update(0)
//end
//
//def Alarm.wakeup(secs256)
//end
//
//def Alarm.wakeupAt(secs256)
//    var etSubs: uint32
//    auto etSecs = EpochTime.getCurrent(&etSubs)
//    auto etTicks = WakeupTimer.timeToTicks(etSecs, etSubs)
//    auto ticks = WakeupTimer.secs256ToTicks(secs256)
//#    %%[a:this.id()]
//#    %%[>etSecs]
//#    %%[>etSubs]
//#    %%[>etTicks]
//#    %%[>ticks]
//    this.setup(ticks - (etTicks % ticks))
//end
//
