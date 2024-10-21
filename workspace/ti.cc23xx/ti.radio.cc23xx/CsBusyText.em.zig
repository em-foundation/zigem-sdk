pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    fiberF: em.Param(FiberMgr.Obj),
};

pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const Common = em.import.@"em.mcu/Common";
pub const FiberMgr = em.import.@"em.utils/FiberMgr";
pub const RadioConfig = em.import.@"ti.radio.cc23xx/RadioConfig";
pub const RadioDriver = em.import.@"ti.radio.cc23xx/RadioDriver";

pub const EM__META = struct {
    pub fn em__configureM() void {
        RadioConfig.phy.set(.PROP_250K);
        const fiberF = FiberMgr.createH(em__U.fxn("fiberFB", FiberMgr.BodyArg));
        em__C.fiberF.set(fiberF);
    }
};

pub const EM__TARG = struct {
    //
    const fiberF = em__C.fiberF;

    const hal = em.hal;
    const reg = em.reg;

    pub fn em__run() void {
        fiberF.post();
        FiberMgr.run();
    }

    pub fn fiberFB(_: FiberMgr.BodyArg) void {
        RadioDriver.enable();
        RadioDriver.startRx(17);
        // RadioDriver.waitReady();
        while (true) {
            Common.BusyWait.wait(1_000_000);
            em.print("rssi = {x}\n", .{RadioDriver.readRssi()});
        }
        // em.halt();
    }
};

//->> zigem publish #|50ac5027a8c88531f27b1cdb1d899ee23ad470d0834d690311c37ca7a18e455f|#

//->> EM__META publics

//->> EM__TARG publics
pub const fiberFB = EM__TARG.fiberFB;

//->> zigem publish -- end of generated code
