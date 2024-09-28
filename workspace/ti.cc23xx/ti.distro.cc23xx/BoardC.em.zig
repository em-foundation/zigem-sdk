pub const em = @import("../../zigem/em.zig");
pub const em__U = em.composite(@This(), .{});

pub const AlarmMgr = em.import.@"em.utils/AlarmMgr";
pub const AppBut = em__U.Generate("AppBut", em.import2.@"em.utils/ButtonT");
pub const AppButEdge = em__U.Generate("AppButEdge", em.import2.@"ti.mcu.cc23xx/GpioEdgeT");
pub const AppLed = em__U.Generate("AppLed", em.import2.@"em.utils/LedT");
pub const AppLedPin = em__U.Generate("AppLedPin", em.import2.@"ti.mcu.cc23xx/GpioT");
pub const AppOutPin = em__U.Generate("AppOutPin", em.import2.@"ti.mcu.cc23xx/GpioT");
pub const AppOutUart = em.import2.@"ti.mcu.cc23xx/ConsoleUart0";
pub const BoardController = em.import.@"em.utils/BoardController";
pub const BusyWait = em.import2.@"ti.mcu.cc23xx/BusyWait";
pub const Common = em.import2.@"em.mcu/Common";
pub const DbgA = em__U.Generate("DbgA", em.import2.@"ti.mcu.cc23xx/GpioT");
pub const DbgB = em__U.Generate("DbgB", em.import2.@"ti.mcu.cc23xx/GpioT");
pub const DbgC = em__U.Generate("DbgC", em.import2.@"ti.mcu.cc23xx/GpioT");
pub const DbgD = em__U.Generate("DbgD", em.import2.@"ti.mcu.cc23xx/GpioT");
pub const Debug = em.import2.@"em.lang/Debug";
pub const EpochTime = em.import.@"em.utils/EpochTime";
pub const ExtFlashDisabler = em.import2.@"ti.mcu.cc23xx/ExtFlashDisabler";
pub const FlashCLK = em__U.Generate("FlashCLK", em.import2.@"ti.mcu.cc23xx/GpioT");
pub const FlashCS = em__U.Generate("FlashCS", em.import2.@"ti.mcu.cc23xx/GpioT");
pub const FlashPICO = em__U.Generate("FlashPICO", em.import2.@"ti.mcu.cc23xx/GpioT");
pub const FlashPOCI = em__U.Generate("FlashPOCI", em.import2.@"ti.mcu.cc23xx/GpioT");
pub const GlobalInterrupts = em.import2.@"em.arch.arm/GlobalInterrupts";
pub const GlobalInterruptsG = em.import2.@"em.mcu/GlobalInterruptsG";
pub const Idle = em.import2.@"ti.mcu.cc23xx/Idle";
pub const Mcu = em.import.@"ti.mcu.cc23xx/Mcu";
pub const MsCounter = em.import.@"ti.mcu.cc23xx/MsCounterGpt3";
pub const OneShot = em.import.@"ti.mcu.cc23xx/OneShotGpt3";
pub const Poller = em.import.@"em.mcu/Poller";
pub const SysLed = em__U.Generate("SysLed", em.import2.@"em.utils/LedT");
pub const SysLedPin = em__U.Generate("SysLedPin", em.import2.@"ti.mcu.cc23xx/GpioT");
pub const Uptimer = em.import.@"ti.mcu.cc23xx/UptimerRtc";
pub const UsCounter = em.import.@"ti.mcu.cc23xx/UsCounterSystick";
pub const WakeupTimer = em.import.@"ti.mcu.cc23xx/WakeupRtc";

pub fn em__configureH() void {
    AlarmMgr.WakeupTimer.set(WakeupTimer);
    AppBut.Edge.set(AppButEdge);
    AppButEdge.c_pin.set(9);
    AppLedPin.c_pin.set(15);
    AppLed.Pin.set(AppLedPin);
    AppOutPin.c_pin.set(20);
    AppOutUart.x_TxPin.set(AppOutPin);
    BoardController.Led.set(SysLed);
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
    EpochTime.Uptimer.set(Uptimer);
    ExtFlashDisabler.x_CLK.set(FlashCLK);
    ExtFlashDisabler.x_CS.set(FlashCS);
    ExtFlashDisabler.x_PICO.set(FlashPICO);
    ExtFlashDisabler.x_POCI.set(FlashPOCI);
    FlashCLK.c_pin.set(18);
    FlashCS.c_pin.set(6);
    FlashPICO.c_pin.set(13);
    FlashPOCI.c_pin.set(12);
    GlobalInterruptsG.x_Impl.set(GlobalInterrupts);
    Poller.OneShot.set(OneShot);
    SysLedPin.c_pin.set(14);
    SysLed.Pin.set(SysLedPin);
}
