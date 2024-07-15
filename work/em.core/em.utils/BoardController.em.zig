pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});
pub const em__C = em__unit.Config(EM__CONFIG);

pub const Common = em.Import.@"em.mcu/Common";

pub const EM__CONFIG = struct {
    Led: em.Proxy(em.Import.@"em.hal/LedI"),
};

pub const EM__HOST = struct {
    pub const Led = em__C.Led.ref();
};

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
