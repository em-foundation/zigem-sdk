const em = @import("../../.gen/em.zig");

pub const em__unit = em.UnitSpec{
    .kind = .module,
    .upath = "gist.cc23xx/Gist03_LedPin",
    .self = @This(),
};

pub const BoardC = em.import.@"em__distro/BoardC";

pub const AppLedPin = em.import.@"scratch.cc23xx/AppLedPin";
pub const BusyWait = em.import.@"scratch.cc23xx/BusyWait";
pub const Mcu = em.import.@"scratch.cc23xx/Mcu";

pub fn em__configureH() void {
    AppLedPin.d_.pin.set(15);
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
