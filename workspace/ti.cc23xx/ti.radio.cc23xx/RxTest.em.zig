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
pub const SysLed = em.import.@"em__distro/BoardC".SysLed;

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

    var pktbuf: [32]u8 = undefined;

    pub fn em__run() void {
        fiberF.post();
        FiberMgr.run();
    }

    pub fn fiberFB(_: FiberMgr.BodyArg) void {
        for (0..20) |_| {
            RadioDriver.enable();
            RadioDriver.startRx(17, 1000);
            RadioDriver.waitReady();
            const pkt = RadioDriver.readPkt(&pktbuf);
            if (pkt.len == 0) {
                SysLed.wink(5);
                em.print("*** timeout\n", .{});
            } else {
                AppLed.wink(5);
                em.print("{x:0>2}, rssi = {d}\n", .{ pkt, RadioDriver.readRssi() });
            }
            RadioDriver.disable();
        }
        em.halt();
    }
};


//->> zigem publish #|66e77d75f6f46c5894dfffb27f953a646b4975a4dc67b635d9d9032e8a338a92|#

//->> EM__META publics

//->> EM__TARG publics
pub const fiberFB = EM__TARG.fiberFB;

//->> zigem publish -- end of generated code
