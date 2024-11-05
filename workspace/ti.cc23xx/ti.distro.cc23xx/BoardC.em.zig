pub const em = @import("../../zigem/em.zig");
pub const em__U = em.composite(@This(), .{});

pub const AlarmMgr = em.import.@"em.utils/AlarmMgr";
pub const AppOutUart = em.import.@"ti.mcu.cc23xx/ConsoleUart0";
pub const BoardController = em.import.@"em.utils/BoardController";
pub const BusyWait = em.import.@"ti.mcu.cc23xx/BusyWait";
pub const Common = em.import.@"em.mcu/Common";
pub const Debug = em.import.@"em.lang/Debug";
pub const ExtFlashDisabler = em.import.@"ti.mcu.cc23xx/ExtFlashDisabler";
pub const GlobalInterrupts = em.import.@"em.arch.arm/GlobalInterrupts";
pub const Idle = em.import.@"ti.mcu.cc23xx/Idle";
pub const Mcu = em.import.@"ti.mcu.cc23xx/Mcu";
pub const MsCounter = em.import.@"ti.mcu.cc23xx/MsCounterGpt3";
pub const OneShot = em.import.@"ti.mcu.cc23xx/OneShotGpt3";
pub const Poller = em.import.@"em.mcu/Poller";
pub const Uptimer = em.import.@"ti.mcu.cc23xx/UptimerRtc";
pub const UsCounter = em.import.@"ti.mcu.cc23xx/UsCounterSystick";
pub const WakeupTimer = em.import.@"ti.mcu.cc23xx/WakeupRtc";

const ButtonT = em.import.@"em.utils/ButtonT";
const EdgeT = em.import.@"ti.mcu.cc23xx/EdgeT";
const GpioT = em.import.@"ti.mcu.cc23xx/GpioT";
const LedT = em.import.@"em.utils/LedT";

pub const AppBut = em__U.Generate("AppBut", ButtonT);
pub const AppButEdge = em__U.Generate("AppButEdge", EdgeT);
pub const AppLed = em__U.Generate("AppLed", LedT);
pub const AppLedPin = em__U.Generate("AppLedPin", GpioT);
pub const AppOutPin = em__U.Generate("AppOutPin", GpioT);
pub const DbgA = em__U.Generate("DbgA", GpioT);
pub const DbgB = em__U.Generate("DbgB", GpioT);
pub const DbgC = em__U.Generate("DbgC", GpioT);
pub const DbgD = em__U.Generate("DbgD", GpioT);
pub const FlashCLK = em__U.Generate("FlashCLK", GpioT);
pub const FlashCS = em__U.Generate("FlashCS", GpioT);
pub const FlashPICO = em__U.Generate("FlashPICO", GpioT);
pub const FlashPOCI = em__U.Generate("FlashPOCI", GpioT);
pub const SysLed = em__U.Generate("SysLed", LedT);
pub const SysLedPin = em__U.Generate("SysLedPin", GpioT);

pub fn em__configureM() void {
    AlarmMgr.x_WakeupTimer.setM(WakeupTimer);
    AppBut.x_Edge.setM(AppButEdge);
    AppButEdge.c_pin.setM(9);
    AppLedPin.c_pin.setM(15);
    AppLed.x_Pin.setM(AppLedPin);
    AppOutPin.c_pin.setM(20);
    AppOutUart.x_TxPin.setM(AppOutPin);
    BoardController.x_Led.setM(SysLed);
    Common.x_BusyWait.setM(BusyWait);
    Common.x_ConsoleUart.setM(AppOutUart);
    Common.x_GlobalInterrupts.setM(GlobalInterrupts);
    Common.x_Idle.setM(Idle);
    Common.x_Mcu.setM(Mcu);
    Common.x_MsCounter.setM(MsCounter);
    Common.x_Uptimer.setM(Uptimer);
    Common.x_UsCounter.setM(UsCounter);
    DbgA.c_pin.setM(23);
    DbgB.c_pin.setM(25);
    DbgC.c_pin.setM(1);
    DbgD.c_pin.setM(2);
    Debug.x_DbgA.setM(DbgA);
    Debug.x_DbgB.setM(DbgB);
    Debug.x_DbgC.setM(DbgC);
    Debug.x_DbgD.setM(DbgD);
    ExtFlashDisabler.x_CLK.setM(FlashCLK);
    ExtFlashDisabler.x_CS.setM(FlashCS);
    ExtFlashDisabler.x_PICO.setM(FlashPICO);
    ExtFlashDisabler.x_POCI.setM(FlashPOCI);
    FlashCLK.c_pin.setM(18);
    FlashCS.c_pin.setM(6);
    FlashPICO.c_pin.setM(13);
    FlashPOCI.c_pin.setM(12);
    Poller.x_OneShot.setM(OneShot);
    SysLedPin.c_pin.setM(14);
    SysLed.x_Pin.setM(SysLedPin);
}


//->> zigem publish #|f64a9565b02e72f4bdb4f596d2658d2576257f4f73700b23b3e7a6bb5253ac0c|#

//->> zigem publish -- end of generated code
