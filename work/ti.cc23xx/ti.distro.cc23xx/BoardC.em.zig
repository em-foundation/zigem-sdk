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
pub const ExtFlashDisabler = em.Import.@"ti.mcu.cc23xx/ExtFlashDisabler";
pub const FlashCLK = em__unit.Generate("FlashCLK", em.Import.@"ti.mcu.cc23xx/GpioT");
pub const FlashCS = em__unit.Generate("FlashCS", em.Import.@"ti.mcu.cc23xx/GpioT");
pub const FlashPICO = em__unit.Generate("FlashPICO", em.Import.@"ti.mcu.cc23xx/GpioT");
pub const FlashPOCI = em__unit.Generate("FlashPOCI", em.Import.@"ti.mcu.cc23xx/GpioT");
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
    AlarmMgr.WakeupTimer.set(WakeupTimer);
    AppLedPin.pin.set(15);
    AppLed.Pin.set(AppLedPin);
    AppOutPin.pin.set(20);
    AppOutUart.TxPin.set(AppOutPin);
    BoardController.Led.set(SysLed);
    Common.BusyWait.set(BusyWait);
    Common.ConsoleUart.set(AppOutUart);
    Common.GlobalInterrupts.set(GlobalInterrupts);
    Common.Idle.set(Idle);
    Common.Mcu.set(Mcu);
    Common.MsCounter.set(MsCounter);
    Common.UsCounter.set(UsCounter);
    DbgA.pin.set(23);
    DbgB.pin.set(25);
    DbgC.pin.set(1);
    DbgD.pin.set(2);
    Debug.DbgA.set(DbgA);
    Debug.DbgB.set(DbgB);
    Debug.DbgC.set(DbgC);
    Debug.DbgD.set(DbgD);
    EpochTime.x_Uptimer.set(Uptimer);
    ExtFlashDisabler.CLK.set(FlashCLK);
    ExtFlashDisabler.CS.set(FlashCS);
    ExtFlashDisabler.PICO.set(FlashPICO);
    ExtFlashDisabler.POCI.set(FlashPOCI);
    FlashCLK.pin.set(18);
    FlashCS.pin.set(6);
    FlashPICO.pin.set(13);
    FlashPOCI.pin.set(12);
    Poller.OneShot.set(OneShot);
    SysLedPin.pin.set(14);
    SysLed.Pin.set(SysLedPin);
}
