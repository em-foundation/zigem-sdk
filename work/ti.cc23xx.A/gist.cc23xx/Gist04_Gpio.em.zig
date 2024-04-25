const em = @import("../../.gen/em.zig");

pub const BoardC = em.import.@"em__distro/BoardC";

pub const AppLedPin = em__unit.Generate(
    "AppLedPin",
    em.import.@"scratch.cc23xx/GpioT",
);
pub const BusyWait = em.import.@"scratch.cc23xx/BusyWait";
pub const Mcu = em.import.@"scratch.cc23xx/Mcu";

pub const em__unit = em.UnitSpec{
    .kind = .module,
    .upath = "gist.cc23xx/Gist04_Gpio",
    .self = @This(),
};

pub fn em__configureH() void {
    AppLedPin.c_pin.set(15);
}

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
