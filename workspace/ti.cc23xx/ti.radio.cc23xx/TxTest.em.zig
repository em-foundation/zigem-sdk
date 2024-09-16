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
    pub fn em__configureH() void {
        RadioConfig.phy.set(.PROP_250K);
    }
    pub fn em__constructH() void {
        em__C.txTicker.set(TickerMgr.createH());
    }
};

pub const EM__TARG = struct {
    //
    const txTicker = em__C.txTicker;

    var data = [_]u32{ 0x0203000F, 0x000A0001, 0x04030201, 0x08070605, 0x00000A09 };

    pub fn em__run() void {
        txTicker.start(256, &txTickCb);
        FiberMgr.run();
    }

    fn txTickCb(_: TickerMgr.CallbackArg) void {
        AppLed.wink(100);
        RadioDriver.setup(.TX, 0);
        RadioDriver.startTx(data[0..]);
    }
};
