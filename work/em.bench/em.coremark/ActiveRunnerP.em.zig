pub const EM__SPEC = null;

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const CoreBench = em.Import.@"em.coremark/CoreBench";
pub const Utils = em.Import.@"em.coremark/Utils";

pub const c_ITERATIONS = em__unit.config("ITERATIONS", u16);

pub const EM__HOST = null;

pub const EM__TARG = null;

pub fn em__run() void {
    em.halt();
}

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
