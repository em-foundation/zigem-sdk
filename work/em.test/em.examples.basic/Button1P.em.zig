pub const em = @import("../../.gen/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    em__upath: []const u8,
};

pub const AppButEdge = em.import.@"em__distro/BoardC".AppButEdge;
pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const Common = em.import.@"em.mcu/Common";

pub const EM__HOST = struct {
    pub fn em__constructH() void {
        AppButEdge.setDetectHandlerH(em__U.fxn("handler", AppButEdge.Handler));
    }
};

pub const EM__TARG = struct {
    //
    pub fn em__startup() void {
        AppButEdge.makeInput();
        AppButEdge.setInternalPullup(true);
        AppButEdge.setDetectFallingEdge();
    }

    pub fn em__run() void {
        Common.GlobalInterrupts.enable();
        while (true) {
            AppButEdge.enableDetect();
            Common.Idle.exec();
        }
    }

    pub fn handler(_: AppButEdge.Handler) void {
        em.@"%%[c]"();
        AppButEdge.clearDetect();
        AppLed.on();
        Common.BusyWait.wait(5000);
        AppLed.off();
    }
};

//package em.examples.basic
//
//from em$distro import BoardC
//from BoardC import AppLed
//
//from em$distro import McuC
//from McuC import AppButEdge
//
//from em.mcu import Common
//
//module Button1P
//
//private:
//
//    function handler: AppButEdge.Handler
//
//end
//
//def em$construct()
//    AppButEdge.setDetectHandlerH(handler)
//end
//
//def em$startup()
//    AppButEdge.makeInput()
//    AppButEdge.setInternalPullup(true)
//    AppButEdge.setDetectFallingEdge()
//end
//
//def em$run()
//    Common.GlobalInterrupts.enable()
//    for ;;
//        AppButEdge.enableDetect()
//        Common.Idle.exec()
//    end
//end
//
//def handler()
//    %%[c]
//    AppButEdge.clearDetect()
//    AppLed.on()
//    Common.BusyWait.wait(5000)
//    AppLed.off()
//end
//
