pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const EM__HOST = struct {
    //
};

pub const EM__TARG = struct {
    //
};

//package em.utils
//
//from em.hal import WakeupTimerI
//
//import EpochTime
//import FiberMgr
//
//module AlarmMgr
//            #   ^|
//    proxy WakeupTimer: WakeupTimerI
//            #   ^|
//    type Alarm: opaque
//            #   ^|
//        host function initH(fiber: FiberMgr.Fiber&)
//            #   ^|
//        function active(): bool
//            #   ^|
//        function cancel()
//            #   ^|
//        function wakeup(secs256: uint32)
//            #   ^|
//        function wakeupAt(secs256: uint32)
//            #   ^|
//    end
//
//    host function createH(fiber: FiberMgr.Fiber&): Alarm&
//            #   ^|
//private:
//
//    def opaque Alarm
//        fiber: FiberMgr.Fiber&
//        thresh: uint32
//        ticks: uint32
//        function id(): uint8
//        function setup(ticks: uint32)
//    end
//
//    function update(deltaTicks: uint32)
//    function wakeupHandler: WakeupTimer.Handler
//
//    var alarmTab: Alarm[..]
//    var curAlarm: Alarm&
//
//end
//
//def createH(fiber)
//    var alarm: Alarm& = alarmTab[alarmTab.length++]
//    alarm.initH(fiber)
//    return alarm
//end
//
//def update(deltaTicks)
//    auto thresh = deltaTicks ? curAlarm.thresh : 0
//    WakeupTimer.disable()
//    auto nxtAlarm = <Alarm&>null
//    var maxTicks: uint32 = ~0       # largest uint32
//    for a in alarmTab
//        continue if a.ticks == 0    # inactive alarm
//        a.ticks -= deltaTicks
//        if a.thresh <= thresh        # expired alarm
//            a.fiber.post()
//        elif a.ticks < maxTicks
//            nxtAlarm = a
//            maxTicks = a.ticks
//        end
//    end
//    return if nxtAlarm == null      # no active alarms
//    curAlarm = nxtAlarm
//    WakeupTimer.enable(curAlarm.thresh, wakeupHandler)
//end
//
//def wakeupHandler()
//    update(curAlarm.ticks)
//end
//
//def Alarm.initH(fiber)
//    this.fiber = fiber
//    this.ticks = 0
//end
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
//    auto ticks = WakeupTimer.secs256ToTicks(secs256)
//    this.setup(ticks)
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
