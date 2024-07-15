pub const em = @import("../../.gen/em.zig");
pub const em__U = em.Module(@This(), .{});

pub const AppLed = em.Import.@"em__distro/BoardC".AppLed;
pub const Common = em.Import.@"em.mcu/Common";
pub const FiberMgr = em.Import.@"em.utils/FiberMgr";
pub const TickerMgr = em.Import.@"em.utils/TickerMgr";
pub const RadioDriver = em.Import.@"ti.radio.cc23xx/RadioDriver";

pub const c_txTicker = em__U.config("txTicker", TickerMgr.Obj);

pub const EM__HOST = struct {
    pub fn em__constructH() void {
        c_txTicker.set(TickerMgr.createH());
    }
};

pub const EM__TARG = struct {
    //
    const txTicker = c_txTicker.unwrap();

    var data = [_]u32{ 0x0203000F, 0x000A0001, 0x04030201, 0x08070605, 0x00000A09 };

    pub fn em__run() void {
        RadioDriver.setup(.TX);
        txTicker.start(256, &txTickCb);
        FiberMgr.run();
    }

    fn txTickCb(_: TickerMgr.Callback) void {
        AppLed.wink(100);
        RadioDriver.startTx(data[0..]);
    }
};
