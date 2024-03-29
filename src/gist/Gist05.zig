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
    for (0..10) |i| {
        BusyWait.wait(100000);
        AppLedPin.toggle();
        AppOut.put('A' + @as(u8, @truncate(i)));
    }
    em.halt();
}
