pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Composite(@This(), .{});

pub const AlarmMgr = em.Import.@"em.utils/AlarmMgr";
pub const AppLed = em__unit.Generate("AppLed", em.Import.@"em.utils/LedT");
pub const AppLedPin = em__unit.Generate("AppLedPin", em.Import.@"ti.mcu.cc23xx/GpioT");
pub const AppOutPin = em__unit.Generate("AppOutPin", em.Import.@"ti.mcu.cc23xx/GpioT");
pub const AppOutUart = em.Import.@"ti.mcu.cc23xx/ConsoleUart0";
pub const BoardController = em.Import.@"em.utils/BoardController";
pub const BusyWait = em.Import.@"ti.mcu.cc23xx/BusyWait";
pub const Console = em.Import.@"em.lang/Console";
pub const Common = em.Import.@"em.mcu/Common";
pub const DbgA = em__unit.Generate("DbgA", em.Import.@"ti.mcu.cc23xx/GpioT");
pub const DbgB = em__unit.Generate("DbgB", em.Import.@"ti.mcu.cc23xx/GpioT");
pub const DbgC = em__unit.Generate("DbgC", em.Import.@"ti.mcu.cc23xx/GpioT");
pub const DbgD = em__unit.Generate("DbgD", em.Import.@"ti.mcu.cc23xx/GpioT");
pub const Debug = em.Import.@"em.lang/Debug";
pub const EpochTime = em.Import.@"em.utils/EpochTime";
pub const GlobalInterrupts = em.Import.@"em.arch.arm/GlobalInterrupts";
pub const Idle = em.Import.@"ti.mcu.cc23xx/Idle";
pub const Mcu = em.Import.@"ti.mcu.cc23xx/Mcu";
pub const MsCounter = em.Import.@"ti.mcu.cc23xx/MsCounterGpt3";
pub const OneShot = em.Import.@"ti.mcu.cc23xx/OneShotGpt3";
pub const Poller = em.Import.@"em.mcu/Poller";
pub const SysLed = em__unit.Generate("SysLed", em.Import.@"em.utils/LedT");
pub const SysLedPin = em__unit.Generate("SysLedPin", em.Import.@"ti.mcu.cc23xx/GpioT");
pub const Uptimer = em.Import.@"ti.mcu.cc23xx/UptimerRtc";
pub const UsCounter = em.Import.@"ti.mcu.cc23xx/UsCounterSystick";
pub const WakeupTimer = em.Import.@"ti.mcu.cc23xx/WakeupRtc";

pub const EM__HOST = struct {};

pub fn em__configureH() void {
    AlarmMgr.x_WakeupTimer.set(WakeupTimer);
    AppLedPin.c_pin.set(15);
    AppLed.x_Pin.set(AppLedPin);
    AppOutPin.c_pin.set(20);
    AppOutUart.x_TxPin.set(AppOutPin);
    BoardController.x_Led.set(SysLed);
    Common.x_BusyWait.set(BusyWait);
    Common.x_ConsoleUart.set(AppOutUart);
    Common.x_GlobalInterrupts.set(GlobalInterrupts);
    Common.x_Idle.set(Idle);
    Common.x_Mcu.set(Mcu);
    Common.x_MsCounter.set(MsCounter);
    Common.x_UsCounter.set(UsCounter);
    DbgA.c_pin.set(23);
    DbgB.c_pin.set(25);
    DbgC.c_pin.set(1);
    DbgD.c_pin.set(2);
    Debug.x_DbgA.set(DbgA);
    Debug.x_DbgB.set(DbgB);
    Debug.x_DbgC.set(DbgC);
    Debug.x_DbgD.set(DbgD);
    EpochTime.x_Uptimer.set(Uptimer);
    Poller.x_OneShot.set(OneShot);
    SysLedPin.c_pin.set(14);
    SysLed.x_Pin.set(SysLedPin);
}
