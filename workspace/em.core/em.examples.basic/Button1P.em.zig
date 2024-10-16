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

    pub fn handler(_: AppButEdge.HandlerArg) void {
        em.@"%%[c]"();
        AppButEdge.clearDetect();
        AppLed.on();
        Common.BusyWait.wait(5000);
        AppLed.off();
    }
};

//->> zigem publish #|a89b3b43b85cb1629feba4f7cbf9537a9e09f247203d7756cf257d5ccb767f6c|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted

//->> EM__META publics

//->> EM__TARG publics
pub const handler = EM__TARG.handler;
