pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{ .inherits = ConsoleUartI });
pub const em__C = em__U.config(EM__CONFIG);

pub const Common = em.import.@"em.mcu/Common";
pub const ConsoleUartI = em.import.@"em.hal/ConsoleUartI";
pub const GpioI = em.import.@"em.hal/GpioI";

pub const EM__CONFIG = struct {
    TxPin: em.Proxy(GpioI),
};

pub const EM__META = struct {
    //
    pub const x_TxPin = em__C.TxPin;
};

pub const EM__TARG = struct {
    //
    const TxPin = em__C.TxPin.unwrap();

    pub fn em__startup() void {
        TxPin.makeOutput();
        TxPin.set();
    }

    pub fn put(data: u8) void {
        if (em.IS_META) return;
        const bit_cnt = 10;
        const bit_time = 8;
        var tx_byte: u16 = (data << 1) | em.as(u16, 0x600); // ST-data8-SP-SP
        const key = Common.GlobalInterrupts.disable();
        for (0..bit_cnt) |_| {
            Common.UsCounter.set(bit_time);
            if ((tx_byte & 0x1) != 0) {
                TxPin.set();
            } else {
                TxPin.clear();
            }
            tx_byte >>= 1;
            Common.UsCounter.spin();
        }
        TxPin.set();
        Common.GlobalInterrupts.restore(key);
    }
};

//#region zigem

//->> zigem publish #|0f5b195afe6143700997bcdb2effb28d47b4482ee656e2acc18543b1c60470d6|#

//->> EM__META publics
pub const x_TxPin = EM__META.x_TxPin;

//->> EM__TARG publics
pub const put = EM__TARG.put;

//->> zigem publish -- end of generated code

//#endregion zigem
