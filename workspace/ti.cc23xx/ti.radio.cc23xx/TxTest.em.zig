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
        RadioConfig.c_phy.setM(.PROP_1M);
    }
    pub fn em__constructM() void {
        em__C.txTicker.setM(TickerMgr.createM());
    }
};

pub const EM__TARG = struct {
    //
    const txTicker = em__C.txTicker.unwrap();

    var dat: u8 = 0;

    var pkt: [5]u8 = undefined;

    pub fn em__run() void {
        txTicker.start(256, &txTickCb);
        pkt[0] = em.as(u8, pkt.len) - 1;
        FiberMgr.run();
    }

    fn txTickCb(_: TickerMgr.CallbackArg) void {
        AppLed.wink(5);
        for (1..pkt.len) |i| {
            pkt[i] = em.as(u8, dat);
            dat += 1;
        }
        RadioDriver.enable();
        RadioDriver.startTx(&pkt, 17, 5);
        RadioDriver.waitReady();
        RadioDriver.disable();
    }
};


//->> zigem publish #|bdd5ffabd78c640241635e91f60967ba30a93b8fe13458e0670c2828f188cb99|#

//->> EM__META publics

//->> EM__TARG publics

//->> zigem publish -- end of generated code
