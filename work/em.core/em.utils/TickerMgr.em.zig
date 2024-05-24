pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const AlarmMgr = em.Import.@"em.utils/AlarmMgr";
pub const FiberMgr = em.Import.@"em.utils/FiberMgr";

pub const Callback = struct {
    arg: em.ptr_t,
};

pub const Ticker = struct {
    const Self = @This();
    _alarm: AlarmMgr.Obj,
    _fiber: FiberMgr.Obj,
    _rate256: u32 = 0,
    _tick_cb: em.Func(em.CB(Callback)),
    pub fn start(self: *Self, rate256: u32, tick_cb: em.Func(em.CB(Callback))) void {
        em__unit.scope.Ticker_start(self, rate256, tick_cb);
    }
    pub fn stop(self: *Self) void {
        em__unit.scope.Ticker_stop(self);
    }
};

pub const a_heap = em__unit.array("a_heap", Ticker);

pub const Obj = em.Ref(Ticker);
pub fn @"->"(obj: Obj) ?*Ticker {
    return a_heap.get(obj);
}

pub const EM__HOST = struct {
    //
    pub fn createH() Obj {
        const fiber = FiberMgr.createH(em__unit.func("alarmFB", em.CB(FiberMgr.FiberBody)));
        const alarm = AlarmMgr.createH(fiber);
        const ticker = a_heap.alloc(.{ ._alarm = alarm, ._fiber = fiber });
        // fiber.arg = ticker.idx
        return ticker;
    }
};

pub const EM__TARG = struct {
    //
    pub fn alarmFB(_: FiberMgr.FiberBody) void {
        //    auto ticker = <Ticker&>arg
        //    return if ticker.tickCb == null
        //    ticker.tickCb()
        //    ticker.alarm.wakeupAt(ticker.rate256)

    }

    pub fn Ticker_start(ticker: *Ticker, rate256: u32, tick_cb: em.Func(em.CB(Callback))) void {
        ticker._rate256 = rate256;
        ticker._tick_cb = tick_cb;
        AlarmMgr.@"->"(ticker._alarm).wakeupAt(rate256);
    }

    pub fn Ticker_stop(ticker: *Ticker) void {
        AlarmMgr.@"->"(ticker._alarm).cancel();
        ticker._tick_cb._fxn = null;
    }
};

//package em.utils
//
//import AlarmMgr
//import FiberMgr
//
//module TickerMgr
//            #   ^|
//    type TickCallback: function()
//            #   ^|
//    type Ticker: opaque
//            #   ^|
//        host function initH()
//            #   ^|
//        function start(rate256: uint32, tickCb: TickCallback)
//            #   ^|
//        function stop()
//            #   ^|
//    end
//
//    host function createH(): Ticker&
//            #   ^|
//private:
//
//    def opaque Ticker
//        alarm: AlarmMgr.Alarm&
//        fiber: FiberMgr.Fiber&
//        rate256: uint32
//        tickCb: TickCallback
//    end
//
//    function alarmFB: FiberMgr.FiberBodyFxn
//
//    var tickerTab: Ticker[]
//
//end
//
//def createH()
//    var ticker: Ticker& = tickerTab[tickerTab.length++]
//    ticker.initH()
//    return ticker
//end
//
//def Ticker.initH()
//    this.fiber = FiberMgr.createH(alarmFB, ^^this.$$cn^^)
//    this.alarm = AlarmMgr.createH(this.fiber)
//end
//
//def alarmFB(arg)
//    auto ticker = <Ticker&>arg
//    return if ticker.tickCb == null
//    ticker.tickCb()
//    ticker.alarm.wakeupAt(ticker.rate256)
//end
//
//def Ticker.start(rate256, tickCb)
//    this.rate256 = rate256
//    this.tickCb = tickCb
//    this.alarm.wakeupAt(rate256)
//end
//
//def Ticker.stop()
//    this.alarm.cancel()
//    this.tickCb = null
//end
//
//
