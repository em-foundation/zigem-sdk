pub const em = @import("../../build/gen/em.zig");
pub const em__T = em.template(@This(), .{});
pub const EM__CONFIG = struct {
    em__upath: []const u8,
    Edge: em.Proxy(em.import.@"em.hal/GpioEdgeI"),
    debounceF: em.Param(FiberMgr.Obj),
};

pub const FiberMgr = em.import.@"em.utils/FiberMgr";

pub fn em__generateS(comptime name: []const u8) type {
    //
    return struct {
        //
        pub const em__U = em.module(@This(), .{
            .inherits = ButtonI,
            .generated = true,
            .name = name,
        });
        pub const em__C = em__U.config(EM__CONFIG);

        pub const ButtonI = em.import.@"em.hal/ButtonI";
        pub const Poller = em.import.@"em.mcu/Poller";

        pub const DurationMs = ButtonI.DurationMs;
        pub const OnPressedCbFxn = ButtonI.OnPressedCbFxn;
        pub const OnPressedCbArg = ButtonI.OnPressedCbArg;

        pub const EM__HOST = struct {
            //
            pub const Edge = em__C.Edge;

            pub fn em__constructH() void {
                const debounceF = FiberMgr.createH(em__U.fxn("debounceFB", FiberMgr.BodyArg));
                em__C.debounceF.set(debounceF);
                // Edge.get().scope().setDetectHandlerH(em__U.fxn("buttonHandler", em__C.Edge.get().scope().HandlerArg));
            }
        };

        pub const EM__TARG = struct {
            //
            const debounceF = em__C.debounceF;
            const Edge = em__C.Edge.scope();

            var cur_cb: OnPressedCbFxn = null;
            var cur_dur: u16 = 0;
            var max_dur: u16 = 0;
            var min_dur: u16 = 0;

            pub fn em__startup() void {
                Edge.makeInput();
                Edge.setInternalPullup(true);
                Edge.setDetectFallingEdge();
            }

            pub fn buttonHandler(_: Edge.HandlerArg) void {
                Edge.clearDetect();
                if (cur_cb != null) debounceF.post();
            }

            pub fn debounceFB(_: FiberMgr.BodyArg) void {
                cur_dur = 0;
                while (true) {
                    Poller.pause(min_dur);
                    if (cur_dur == 0 and !isPressed()) return;
                    cur_dur += min_dur;
                    if (!isPressed() or cur_dur >= max_dur) break;
                }
                cur_cb.?(.{});
            }

            pub fn isPressed() bool {
                return !Edge.get();
            }

            pub fn onPressed(cb: OnPressedCbFxn, dur: DurationMs) void {
                cur_cb = cb;
                max_dur = dur.max;
                min_dur = dur.max;
                if (cb == null) {
                    Edge.disableDetect();
                } else {
                    Edge.enableDetect();
                }
            }
        };
    };
}

//|->>>
//    ## ---- generated by em.utils/ButtonT ---- ##
//    package `pn`
//
//    from em.hal import ButtonI
//    from em.hal import GpioEdgeDetectMinI
//
//    from em.mcu import Poller
//
//    from em.utils import FiberMgr
//
//    module `un`: ButtonI
//        #   ^| implements the ButtonI interface
//        proxy Edge: GpioEdgeDetectMinI
//        #   ^| a GPIO with edge-detection capabilities
//    private:
//
//        function buttonHandler: Edge.Handler
//        function debounceFB: FiberMgr.FiberBodyFxn
//
//        config debounceF: FiberMgr.Fiber&
//
//        var curDuration: uint16
//        var curCb: OnPressedCB
//        var maxDur: uint16
//        var minDur: uint16
//
//    end
//
//    def em$construct()
//        Edge.setDetectHandlerH(buttonHandler)
//        debounceF = FiberMgr.createH(debounceFB)
//    end
//
//    def em$startup()
//        Edge.makeInput()
//        Edge.setInternalPullup(true)
//        Edge.setDetectFallingEdge()
//    end
//
//    def buttonHandler()
//        Edge.clearDetect()
//        debounceF.post() if curCb
//    end
//
//    def debounceFB(arg)
//        curDuration = 0
//        for ;;
//            Poller.pause(minDur)
//            return if curDuration == 0 && !isPressed()
//            curDuration += minDur
//            break if !isPressed() || curDuration >= maxDur
//        end
//        curCb()
//    end
//
//    def isPressed()
//        return !Edge.get()
//    end
//
//    def onPressed(cb, minDurationMs, maxDurationMs)
//        curCb = cb
//        maxDur = maxDurationMs
//        minDur = minDurationMs
//        if cb == null
//            Edge.disableDetect()
//        else
//            Edge.enableDetect()
//        end
//    end
//|-<<<
//
