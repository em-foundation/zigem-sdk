const em = @import("../em.zig");

const BusyWait = @import("../scratch/BusyWait.zig");
const GpioMgr = @import("../scratch/GpioMgr.zig");
const Mcu = @import("../scratch/Mcu.zig");

const AppLedPin = GpioMgr.create(15);

pub fn @"em$run"() void {
    Mcu.startup();
    AppLedPin.makeOutput();
    for (0..10) |_| {
        BusyWait.wait(100000);
        AppLedPin.toggle();
    }
    em.halt();
}
