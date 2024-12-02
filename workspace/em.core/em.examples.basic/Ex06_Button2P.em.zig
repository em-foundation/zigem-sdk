pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    blinkF: em.Param(FiberMgr.Obj),
};

pub const AppButEdge = em.import.@"em__distro/BoardC".AppButEdge;
pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const Common = em.import.@"em.mcu/Common";
pub const FiberMgr = em.import.@"em.utils/FiberMgr";

pub const EM__META = struct {
    //
    pub fn em__constructM() void {
        AppButEdge.setDetectHandlerM(em__U.fxn("handler", AppButEdge.HandlerArg));
        const blinkF = FiberMgr.createM(em__U.fxn("blinkFB", FiberMgr.BodyArg));
        em__C.blinkF.setM(blinkF);
    }
};

pub const EM__TARG = struct {
    //
    pub fn em__startup() void {
        AppButEdge.init(true);
        AppButEdge.setDetectFallingEdge();
    }

    pub fn em__run() void {
        AppButEdge.enableDetect();
        FiberMgr.run();
    }

    pub fn blinkFB(_: FiberMgr.BodyArg) void {
        em.@"%%[d]"();
        AppLed.on();
        Common.BusyWait.wait(5000);
        AppLed.off();
        AppButEdge.enableDetect();
    }

    pub fn handler(_: AppButEdge.HandlerArg) void {
        em.@"%%[c]"();
        AppButEdge.clearDetect();
        em__C.blinkF.unwrap().post();
    }
};

//#region zigem

//->> zigem publish #|e5aff7aa38aca43e11ae0af5f26e497c670fdc3b5b458ea3b802902e59d2a64e|#

//->> EM__META publics

//->> EM__TARG publics
pub const blinkFB = EM__TARG.blinkFB;
pub const handler = EM__TARG.handler;

//->> zigem publish -- end of generated code

//#endregion zigem
