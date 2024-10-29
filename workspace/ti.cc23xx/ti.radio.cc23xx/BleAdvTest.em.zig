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
    pub fn em__configureM() void {
        RadioConfig.c_phy.setM(.BLE_1M);
    }
    pub fn em__constructM() void {
        em__C.txTicker.setM(TickerMgr.createM());
    }
};

pub const EM__TARG = struct {
    //
    const txTicker = em__C.txTicker.unwrap();

    var data = [_]u32{ 0x02030014, 0x0E220001, 0xBBBBCCCC, 0x0804AAAA, 0x0247495A, 0x00000601 };
    var pkt = [_]u8{ 0x22, 0x0E, 0xCC, 0xCC, 0xBB, 0xBB, 0xAA, 0xAA, 0x04, 0x08, 0x5A, 0x49, 0x47, 0x02, 0x01, 0x06 };

    pub fn em__run() void {
        txTicker.start(256, &txTickCb);
        FiberMgr.run();
    }

    fn txTickCb(_: TickerMgr.CallbackArg) void {
        AppLed.wink(5);
        RadioDriver.enable();
        var chan: u8 = 37;
        while (chan < 40) : (chan += 1) {
            RadioDriver.startTx(&pkt, chan, 5);
            RadioDriver.waitReady();
        }
        RadioDriver.disable();
    }
};


//->> zigem publish #|b00bf81eaa258b524ce83f65195541cf3cb3a6c4161ce35a4bbde2367176cb91|#

//->> EM__META publics

//->> EM__TARG publics

//->> zigem publish -- end of generated code
