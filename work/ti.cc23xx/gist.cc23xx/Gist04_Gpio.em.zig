pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const AppLedPin = em__unit.Generate("AppLedPin", em.Import.@"scratch.cc23xx/GpioT");
pub const BusyWait = em.Import.@"scratch.cc23xx/BusyWait";
pub const Mcu = em.Import.@"scratch.cc23xx/Mcu";

pub const EM__HOST = struct {};

pub fn em__configureH() void {
    AppLedPin.c_pin.set(15);
}

pub const EM__TARG = struct {};

pub fn em__startup() void {
    Mcu.startup();
}

pub fn em__run() void {
    AppLedPin.makeOutput();
    for (0..10) |_| {
        BusyWait.wait(100000);
        AppLedPin.toggle();
    }
}
