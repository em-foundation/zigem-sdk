const em = @import("../em.zig");

const AppLedPin = @import("../scratch/AppLedPin.zig");
const BusyWait = @import("../scratch/BusyWait.zig");

pub fn @"em$run"() void {
    AppLedPin.makeOutput();
    var i: u8 = 0;
    while (i < 10) : (i += 1) {
        BusyWait.wait(100000);
        AppLedPin.toggle();
    }
    em.halt();
}
