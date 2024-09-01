pub const em = @import("../../zigem/gen/em.zig");
pub const em__U = em.module(@This(), .{});

pub const CoreBench = em.import.@"em.coremark/CoreBench";
pub const Utils = em.import.@"em.coremark/Utils";

pub const ITERATIONS: u16 = 10;

pub const EM__HOST = struct {};

pub const EM__TARG = struct {
    //
    pub fn em__startup() void {
        CoreBench.setup();
    }

    pub fn em__run() void {
        em.@"%%[d+]"();
        for (0..ITERATIONS) |_| {
            _ = CoreBench.run(0);
        }
        em.@"%%[d-]"();
        em.print("z: list crc = {x:0>4}\n", .{Utils.getCrc(.LIST)});
        em.print("z: matrix crc = {x:0>4}\n", .{Utils.getCrc(.MATRIX)});
        em.print("z: state crc = {x:0>4}\n", .{Utils.getCrc(.STATE)});
        em.print("z: final crc = {x:0>4}\n", .{Utils.getCrc(.FINAL)});
    }
};

//package em.coremark
//
//from em$distro import BoardC
//from BoardC import AppLed
//
//from em.mcu import Common
//
//import CoreBench
//import Utils
//
//module ActiveRunnerP
//
//    config ITERATIONS: uint16 = 10
//
//end
//
//def em$startup()
//    CoreBench.setup()
//end
//
//def em$run()
//    AppLed.on()
//    Common.BusyWait.wait(250000)
//    AppLed.off()
//    Common.UsCounter.start()
//    %%[d+]
//    for auto i = 0; i < ITERATIONS; i++
//        CoreBench.run()
//    end
//    %%[d-]
//    auto usecs = Common.UsCounter.stop()
//    AppLed.on()
//    Common.BusyWait.wait(250000)
//    AppLed.off()
//    printf "usecs = %d\n", usecs
//    printf "list crc = %04x\n", Utils.getCrc(Utils.Kind.LIST)
//    printf "matrix crc = %04x\n", Utils.getCrc(Utils.Kind.MATRIX)
//    printf "state crc = %04x\n", Utils.getCrc(Utils.Kind.STATE)
//    printf "final crc = %04x\n", Utils.getCrc(Utils.Kind.FINAL)
//end
//
//
