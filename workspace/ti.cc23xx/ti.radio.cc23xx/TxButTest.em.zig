pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    em__upath: []const u8,
    xmitF: em.Param(FiberMgr.Obj),
};

pub const AppButEdge = em.import.@"em__distro/BoardC".AppButEdge;
pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const Common = em.import.@"em.mcu/Common";
pub const FiberMgr = em.import.@"em.utils/FiberMgr";
pub const Idle = em.import.@"ti.mcu.cc23xx/Idle";
pub const RadioDriver = em.import.@"ti.radio.cc23xx/RadioDriver";

pub const EM__META = struct {
    pub fn em__constructM() void {
        AppButEdge.setDetectHandlerH(em__U.fxn("handler", AppButEdge.HandlerArg));
        const xmitF = FiberMgr.createH(em__U.fxn("xmitFB", FiberMgr.BodyArg));
        em__C.xmitF.set(xmitF);
    }
};

pub const EM__TARG = struct {
    //
    const xmitF = em__C.xmitF;

    var data = [_]u32{ 0x0203000F, 0x000A0001, 0x04030201, 0x08070605, 0x00000A09 };

    pub fn em__startup() void {
        AppButEdge.makeInput();
        AppButEdge.setInternalPullup(true);
        AppButEdge.setDetectFallingEdge();
    }

    pub fn em__run() void {
        AppButEdge.enableDetect();
        FiberMgr.run();
    }

    pub fn xmitFB(_: FiberMgr.BodyArg) void {
        AppLed.wink(100);
        RadioDriver.setup(.TX);
        RadioDriver.startTx(data[0..]);
        AppButEdge.enableDetect();
    }

    pub fn handler(_: AppButEdge.HandlerArg) void {
        em.@"%%[c]"();
        AppButEdge.clearDetect();
        xmitF.post();
    }
};

//->> zigem publish #|91da862cae507a9b441ec1a64ed2b6999553a98e5c3da7da0f83f7c983b4fa95|#

//->> EM__META publics

//->> EM__TARG publics
pub const xmitFB = EM__TARG.xmitFB;
pub const handler = EM__TARG.handler;

//->> zigem publish -- end of generated code
