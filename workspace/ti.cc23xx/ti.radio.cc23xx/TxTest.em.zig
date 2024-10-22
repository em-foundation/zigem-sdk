pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    txTicker: em.Param(TickerMgr.Obj),
};

pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const Common = em.import.@"em.mcu/Common";
pub const FiberMgr = em.import.@"em.utils/FiberMgr";
pub const TickerMgr = em.import.@"em.utils/TickerMgr";
pub const RadioConfig = em.import.@"ti.radio.cc23xx/RadioConfig";
pub const RadioDriver = em.import.@"ti.radio.cc23xx/RadioDriver";

pub const EM__META = struct {
    //
    pub fn em__configureM() void {
        RadioConfig.c_phy.setM(.PROP_250K);
    }
    pub fn em__constructM() void {
        em__C.txTicker.setM(TickerMgr.createM());
    }
};

pub const EM__TARG = struct {
    //
    const txTicker = em__C.txTicker.unwrap();

    var data = [_]u32{ 0x0203000E, 0x00090001, 0x04030201, 0x08070605, 0x00000009 };

    pub fn em__run() void {
        txTicker.start(256, &txTickCb);
        FiberMgr.run();
    }

    fn txTickCb(_: TickerMgr.CallbackArg) void {
        AppLed.wink(5);
        RadioDriver.enable();
        RadioDriver.putWords(&data);
        RadioDriver.startTx(17, 5);
        RadioDriver.waitReady();
        RadioDriver.disable();
    }
};


//->> zigem publish #|c803f73deaaf74f161349072c3197be59a99f6bfb79606be15f59b5324017c42|#

//->> EM__META publics

//->> EM__TARG publics

//->> zigem publish -- end of generated code
