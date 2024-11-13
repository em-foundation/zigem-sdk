pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    em__upath: []const u8,
};

pub const AppButEdge = em.import.@"em__distro/BoardC".AppButEdge;
pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const Common = em.import.@"em.mcu/Common";

pub const EM__META = struct {
    //
    pub fn em__constructM() void {
        AppButEdge.setDetectHandlerM(em__U.fxn("handler", AppButEdge.HandlerArg));
    }
};

pub const EM__TARG = struct {
    //
    pub fn em__startup() void {
        AppButEdge.init(true);
        AppButEdge.setDetectFallingEdge();
    }

    pub fn em__run() void {
        Common.GlobalInterrupts.enable();
        while (true) {
            AppButEdge.enableDetect();
            Common.Idle.exec();
        }
    }

    pub fn handler(_: AppButEdge.HandlerArg) void {
        em.@"%%[c]"();
        AppButEdge.clearDetect();
        AppLed.on();
        Common.BusyWait.wait(5000);
        AppLed.off();
    }
};

//#region zigem

//->> zigem publish #|9fbd3e112114f2a9fca3e0b2ca82704d4b82396d0ca9d9831174e3f95ecec93e|#

//->> EM__META publics

//->> EM__TARG publics
pub const handler = EM__TARG.handler;

//->> zigem publish -- end of generated code

//#endregion zigem
