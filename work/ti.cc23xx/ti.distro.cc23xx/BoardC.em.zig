pub const EM__SPEC = {};

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Composite(@This(), .{});

pub const AppLed = em__unit.Generate("AppLed", em.Import.@"em.utils/LedT");
pub const AppLedPin = em__unit.Generate("AppLedPin", em.Import.@"ti.mcu.cc23xx/GpioT");
pub const AppOutPin = em__unit.Generate("AppOutPin", em.Import.@"ti.mcu.cc23xx/GpioT");
pub const AppOutUart = em.Import.@"ti.mcu.cc23xx/ConsoleUart0";
pub const BoardController = em.Import.@"em.utils/BoardController";
pub const BusyWait = em.Import.@"ti.mcu.cc23xx/BusyWait";
pub const Common = em.Import.@"em.mcu/Common";
pub const Hal = em.Import.@"ti.mcu.cc23xx/Hal";
pub const LinkerC = em.Import.@"em.build.misc/LinkerC";
pub const Mcu = em.Import.@"ti.mcu.cc23xx/Mcu";
pub const StartupC = em.Import.@"em.arch.arm/StartupC";
pub const SysLed = em__unit.Generate("SysLed", em.Import.@"em.utils/LedT");
pub const SysLedPin = em__unit.Generate("SysLedPin", em.Import.@"ti.mcu.cc23xx/GpioT");

pub const EM__HOST = {};

pub fn em__configureH() void {
    AppLedPin.c_pin.set(15);
    AppLed.x_Pin.set(AppLedPin);
    AppOutPin.c_pin.set(20);
    AppOutUart.x_TxPin.set(AppOutPin);
    Common.x_BusyWait.set(BusyWait);
    Common.x_ConsoleUart.set(AppOutUart);
    Common.x_Mcu.set(Mcu);
    SysLedPin.c_pin.set(14);
    SysLed.x_Pin.set(SysLedPin);
}
