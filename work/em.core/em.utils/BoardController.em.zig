pub const EM__SPEC = {};

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const Common = em.Import.@"em.mcu/Common";

pub const x_Led = em__unit.Proxy("Led", em.Import.@"em.hal/LedI");

pub const EM__HOST = {};

pub const EM__TARG = {};

const blinkRate = 50000;
const EOT_BYTE = 0x4;
const Led = x_Led.unwrap();
const SOT_BYTE = 0x3;
const SOT_COUNT = 13;
const Uart = Common.ConsoleUart;

pub fn em__reset() void {
    Common.Mcu.startup();
}

pub fn em__ready() void {
    Led.off();
    blink(2, blinkRate);
    Uart.flush();
    Uart.put(0);
    Uart.put(0);
    for (0..SOT_COUNT) |_| {
        Uart.put(SOT_BYTE);
    }
    Uart.flush();
}

pub fn em__fail() void {}

pub fn em__halt() void {}

fn blink(times: u8, usecs: u32) void {
    for (0..times * 2) |_| {
        Led.toggle();
        Common.BusyWait.wait(usecs);
    }
}
