pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const AlarmMgr = em.Import.@"em.utils/AlarmMgr";
pub const AppLed = em.Import.@"em__distro/BoardC".AppLed;
pub const FiberMgr = em.Import.@"em.utils/FiberMgr";

pub const c_alarm = em__unit.config("alarm", AlarmMgr.Obj);
pub const c_blinkF = em__unit.config("blinkF", FiberMgr.Obj);

pub const EM__HOST = struct {
    //
    pub fn em__constructH() void {
        c_blinkF.set(FiberMgr.createH(em__unit.func("blinkFB", em.CB(FiberMgr.FiberBody))));
        c_alarm.set(AlarmMgr.createH(c_blinkF.get()));
    }
};

pub const EM__TARG = struct {
    //
    const alarm = AlarmMgr.@"->"(c_alarm.unwrap()).?;
    const blinkF = FiberMgr.@"->"(c_blinkF.unwrap()).?;
    var counter: u32 = 0;

    pub fn em__run() void {
        blinkF.post();
        FiberMgr.run();
    }

    pub fn blinkFB(_: FiberMgr.FiberBody) void {
        em.@"%%[c]"();
        AppLed.wink(100); // 100 ms
        counter += 1;
        if ((counter & 0x1) != 0) {
            alarm.wakeup(512); // 2s
        } else {
            alarm.wakeup(192); // 750ms
        }
    }
};

//package em.examples.basic
//
//from em$distro import BoardC
//from BoardC import AppLed
//
//from em.utils import AlarmMgr
//from em.utils import FiberMgr
//
//module Alarm1P
//
//private:
//
//    function blinkFB: FiberMgr.FiberBodyFxn
//
//    config alarm: AlarmMgr.Alarm&
//    config blinkF: FiberMgr.Fiber&
//
//    var counter: uint32
//
//end
//
//def em$construct()
//    blinkF = FiberMgr.createH(blinkFB)
//    alarm = AlarmMgr.createH(blinkF)
//end
//
//def em$run()
//    blinkF.post()
//    FiberMgr.run()
//end
//
//def blinkFB(arg)
//    %%[c]
//    AppLed.wink(100)            # 100ms
//    counter += 1
//    if counter & 0x1
//        alarm.wakeup(512)       # 2s
//    else
//        alarm.wakeup(192)       # 750ms
//    end
//end
//
//
