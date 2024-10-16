pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    Led: em.Proxy(LedI),
};
pub const x_Led = em__C.Led;

pub const Common = em.import.@"em.mcu/Common";
pub const LedI = em.import.@"em.hal/LedI";

pub const EM__TARG = struct {
    //
    const blinkRate = 50000;
    const EOT_BYTE = 0x4;
    const Led = em__C.Led.unwrap();
    const SOT_BYTE = 0x3;
    const SOT_COUNT = 13;

    pub fn em__reset() void {
        Common.Mcu.startup();
    }

    pub fn em__ready() void {
        Led.off();
        blink(2, blinkRate);
        Common.ConsoleUart.flush();
        Common.ConsoleUart.put(0);
        Common.ConsoleUart.put(0);
        for (0..SOT_COUNT) |_| {
            Common.ConsoleUart.put(SOT_BYTE);
        }
        Common.ConsoleUart.flush();
    }

    pub fn em__fail() void {
        _ = Common.GlobalInterrupts.disable();
        while (true) {
            blink(2, blinkRate);
        }
    }

    pub fn em__halt() void {
        _ = Common.GlobalInterrupts.disable();
        Common.ConsoleUart.put(EOT_BYTE);
        Common.ConsoleUart.flush();
        Led.on();
    }

    fn blink(times: u8, usecs: u32) void {
        for (0..times * 2) |_| {
            Led.toggle();
            Common.BusyWait.wait(usecs);
        }
    }
};

//->> zigem publish #|e5fa3f18d2dcf099b1bc1468f3905d82448965c5d8ab05cac9df7fb2e67ecf18|#

//->> generated source code -- do not modify
//->> all of these lines can be safely deleted

//->> EM__TARG publics
