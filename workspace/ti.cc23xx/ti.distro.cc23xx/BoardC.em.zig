pub const em = @import("../../zigem/em.zig");
pub const em__U = em.composite(@This(), .{});

pub const BoardInfoC = em.import.@"em.lang/BoardInfoC";

pub const AlarmMgr = em.import.@"em.utils/AlarmMgr";
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
pub const UsCounter = em.import.@"em.arch.arm/UsCounterSystick";
pub const WakeupTimer = em.import.@"ti.mcu.cc23xx/WakeupRtc";

const ButtonT = em.import.@"em.utils/ButtonT";
const EdgeT = em.import.@"ti.mcu.cc23xx/EdgeT";
const GpioT = em.import.@"ti.mcu.cc23xx/GpioT";
const LedT = em.import.@"em.utils/LedT";

pub const AppBut = em__U.Generate("AppBut", ButtonT, .{});
pub const AppButEdge = em__U.Generate("AppButEdge", EdgeT, .{});
pub const AppLed = em__U.Generate("AppLed", LedT, .{});
pub const AppLedPin = em__U.Generate("AppLedPin", GpioT, .{});
pub const AppOutPin = em__U.Generate("AppOutPin", GpioT, .{});
pub const DbgA = em__U.Generate("DbgA", GpioT, .{});
pub const DbgB = em__U.Generate("DbgB", GpioT, .{});
pub const DbgC = em__U.Generate("DbgC", GpioT, .{});
pub const DbgD = em__U.Generate("DbgD", GpioT, .{});
pub const FlashCLK = em__U.Generate("FlashCLK", GpioT, .{});
pub const FlashCS = em__U.Generate("FlashCS", GpioT, .{});
pub const FlashPICO = em__U.Generate("FlashPICO", GpioT, .{});
pub const FlashPOCI = em__U.Generate("FlashPOCI", GpioT, .{});
pub const SysLed = em__U.Generate("SysLed", LedT, .{});
pub const SysLedPin = em__U.Generate("SysLedPin", GpioT, .{});

pub const BoardInfo = struct {
    activeLowLed: bool = false,
    useSoftUart: bool = false,
    Pin_AppBut: i16 = -1,
    Pin_AppLed: i16 = -1,
    Pin_AppOut: i16 = -1,
    Pin_DbgA: i16 = -1,
    Pin_DbgB: i16 = -1,
    Pin_DbgC: i16 = -1,
    Pin_DbgD: i16 = -1,
    Pin_FlashCLK: i16 = -1,
    Pin_FlashCS: i16 = -1,
    Pin_FlashPICO: i16 = -1,
    Pin_FlashPOCI: i16 = -1,
    Pin_SysLed: i16 = -1,
};

pub fn LP_EM_CC2340R5(b: *BoardInfo) void {
    b.Pin_AppBut = 9;
    b.Pin_AppLed = 15;
    b.Pin_AppOut = 20;
    b.Pin_DbgA = 23;
    b.Pin_DbgB = 25;
    b.Pin_DbgC = 1;
    b.Pin_DbgD = 2;
    b.Pin_FlashCLK = 18;
    b.Pin_FlashCS = 6;
    b.Pin_FlashPICO = 13;
    b.Pin_FlashPOCI = 12;
    b.Pin_SysLed = 14;
}

pub fn LP_EM_CC2340R5_HUB(b: *BoardInfo) void {
    LP_EM_CC2340R5(b);
    b.useSoftUart = true;
    b.Pin_AppOut = 0;
}

const BOARD: BoardInfo = BoardInfoC.initFrom(em__U.This);

pub const AppOutUart = if (BOARD.useSoftUart) em.import.@"em.utils/SoftUart" else em.import.@"ti.mcu.cc23xx/ConsoleUart0";

pub fn em__configureM() void {
    AlarmMgr.x_WakeupTimer.setM(WakeupTimer);
    AppBut.x_Edge.setM(AppButEdge);
    AppButEdge.c_pin.setM(BOARD.Pin_AppBut);
    AppLedPin.c_pin.setM(BOARD.Pin_AppLed);
    AppLed.x_Pin.setM(AppLedPin);
    AppLed.c_active_low.setM(BOARD.activeLowLed);
    AppOutPin.c_pin.setM(BOARD.Pin_AppOut);
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
    DbgA.c_pin.setM(BOARD.Pin_DbgA);
    DbgB.c_pin.setM(BOARD.Pin_DbgB);
    DbgC.c_pin.setM(BOARD.Pin_DbgC);
    DbgD.c_pin.setM(BOARD.Pin_DbgD);
    Debug.x_DbgA.setM(DbgA);
    Debug.x_DbgB.setM(DbgB);
    Debug.x_DbgC.setM(DbgC);
    Debug.x_DbgD.setM(DbgD);
    ExtFlashDisabler.x_CLK.setM(FlashCLK);
    ExtFlashDisabler.x_CS.setM(FlashCS);
    ExtFlashDisabler.x_PICO.setM(FlashPICO);
    ExtFlashDisabler.x_POCI.setM(FlashPOCI);
    FlashCLK.c_pin.setM(BOARD.Pin_FlashCLK);
    FlashCS.c_pin.setM(BOARD.Pin_FlashCS);
    FlashPICO.c_pin.setM(BOARD.Pin_FlashPICO);
    FlashPOCI.c_pin.setM(BOARD.Pin_FlashPOCI);
    Poller.x_OneShot.setM(OneShot);
    SysLedPin.c_pin.setM(BOARD.Pin_SysLed);
    SysLed.x_Pin.setM(SysLedPin);
    SysLed.c_active_low.setM(BOARD.activeLowLed);
}

//#region zigem

//->> zigem publish #|25b8e801accba5be95a343ef0bd4347c70e5930f93af93bb2c0ef6d2b871708e|#

//->> zigem publish -- end of generated code

//#endregion zigem
