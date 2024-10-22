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
    //
    pub fn em__configureM() void {
        RadioConfig.c_phy.setM(.PROP_250K);
        const fiberF = FiberMgr.createM(em__U.fxn("fiberFB", FiberMgr.BodyArg));
        em__C.fiberF.setM(fiberF);
    }
};

pub const EM__TARG = struct {
    //
    const fiberF = em__C.fiberF.unwrap();

    const hal = em.hal;
    const reg = em.reg;

    pub fn em__run() void {
        fiberF.post();
        FiberMgr.run();
    }

    pub fn fiberFB(_: FiberMgr.BodyArg) void {
        RadioDriver.enable();
        RadioDriver.startRx(17, 0);
        RadioDriver.waitReady();
        em.halt();
    }
};


//->> zigem publish #|e38e65093f90fe8ae1cce0683225131fe204636d40f7d6bc1e81608f7c6fd1be|#

//->> EM__META publics

//->> EM__TARG publics
pub const fiberFB = EM__TARG.fiberFB;

//->> zigem publish -- end of generated code
