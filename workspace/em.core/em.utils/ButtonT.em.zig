pub const em = @import("../../zigem/em.zig");
pub const em__T = em.template(@This(), .{});
pub const EM__CONFIG = struct {
    em__upath: []const u8,
    Edge: em.Proxy(GpioEdgeI),
    debounceF: em.Param(FiberMgr.Obj),
};

pub const FiberMgr = em.import2.@"em.utils/FiberMgr";
pub const GpioEdgeI = em.import2.@"em.hal/GpioEdgeI";

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

        pub const ButtonI = em.import2.@"em.hal/ButtonI";
        pub const Poller = em.import2.@"em.mcu/Poller";

        pub const x_Edge = em__C.Edge;

        pub const DurationMs = ButtonI.DurationMs;
        pub const OnPressedCbFxn = ButtonI.OnPressedCbFxn;
        pub const OnPressedCbArg = ButtonI.OnPressedCbArg;

        // -------- META --------

        pub fn em__constructH() void {
            const fiber = FiberMgr.createH(em__U.fxn("debounceFB", FiberMgr.BodyArg));
            em__C.debounceF.set(fiber);
            em__C.Edge.get().setDetectHandlerH(em__U.fxn("buttonHandler", GpioEdgeI.HandlerArg));
        }

        // -------- TARG --------

        const Edge = em__C.Edge.get();

        var cur_cb: OnPressedCbFxn = null;
        var cur_dur: u16 = 0;
        var max_dur: u16 = 0;
        var min_dur: u16 = 0;

        pub fn em__startup() void {
            Edge.makeInput();
            Edge.setInternalPullup(true);
            Edge.setDetectFallingEdge();
        }

        pub fn buttonHandler(_: GpioEdgeI.HandlerArg) void {
            Edge.clearDetect();
            if (cur_cb != null) em__C.debounceF.get().post();
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
            min_dur = dur.min;
            if (cb == null) {
                Edge.disableDetect();
            } else {
                Edge.enableDetect();
            }
        }
    };
}
