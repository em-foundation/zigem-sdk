const em = @import("../em.zig");

const AppLedPin = @import("../scratch/AppLedPin.zig");
const BusyWait = @import("../scratch/BusyWait.zig");

pub fn @"em$run"() void {
    AppLedPin.makeOutput();
    for (0..10) |_| {
        BusyWait.wait(100000);
        AppLedPin.toggle();
    }
    em.halt();
}
