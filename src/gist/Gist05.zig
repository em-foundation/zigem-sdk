const em = @import("../em.zig");

const AppOut = @import("../scratch/AppOut.zig");
const BusyWait = @import("../scratch/BusyWait.zig");
const GpioMgr = @import("../scratch/GpioMgr.zig");
const Mcu = @import("../scratch/Mcu.zig");

const AppLedPin = GpioMgr.create(15);

pub fn @"em$startup"() void {
    Mcu.startup();
    AppOut.@"em$startup"();
    AppLedPin.makeOutput();
}

pub fn @"em$run"() void {
    var i: u8 = 0;
    while (i < 10) : (i += 1) {
        BusyWait.wait(100000);
        AppLedPin.toggle();
        AppOut.put('A' + i);
    }
    em.halt();
}
