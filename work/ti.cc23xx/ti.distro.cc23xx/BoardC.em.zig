pub const EM__SPEC = {};

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Composite(@This(), .{});

pub const AppLed = em__unit.Generate("AppLed", em.Import.@"em.utils/LedT");
pub const AppLedPin = em__unit.Generate("AppLedPin", em.Import.@"ti.mcu.cc23xx/GpioT");
pub const BusyWait = em.Import.@"ti.mcu.cc23xx/BusyWait";
pub const Common = em.Import.@"em.mcu/Common";
pub const Hal = em.Import.@"ti.mcu.cc23xx/Hal";
pub const LinkerC = em.Import.@"em.build.misc/LinkerC";
pub const StartupC = em.Import.@"em.arch.arm/StartupC";
pub const SysLed = em__unit.Generate("SysLed", em.Import.@"em.utils/LedT");
pub const SysLedPin = em__unit.Generate("SysLedPin", em.Import.@"ti.mcu.cc23xx/GpioT");

pub const EM__HOST = {};

pub fn em__configureH() void {
    AppLedPin.c_pin.set(15);
    AppLed.x_Pin.set(AppLedPin);
    Common.x_BusyWait.set(BusyWait);
    SysLedPin.c_pin.set(14);
    SysLed.x_Pin.set(SysLedPin);
}
