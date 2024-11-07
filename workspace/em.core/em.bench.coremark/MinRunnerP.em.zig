pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const Common = em.import.@"em.mcu/Common";
pub const CoreBench = em.import.@"em.bench.coremark/CoreBench";
pub const Utils = em.import.@"em.bench.coremark/Utils";

pub const ITERATIONS: u16 = 10;

pub const EM__TARG = struct {
    //
    pub fn em__startup() void {
        CoreBench.setup();
    }

    pub fn em__run() void {
        em.@"%%[d+]"();
        Common.UsCounter.start();
        for (0..ITERATIONS) |_| {
            _ = CoreBench.run(0);
        }
        em.@"%%[d-]"();
        var raw: u32 = undefined;
        const us = Common.UsCounter.stop(&raw);
        em.print("raw = {d}, us = {d}\n", .{ raw, us });
    }
};


//->> zigem publish #|4e583449d7ab60bb9e50d02aa0340faba5aaaadfe4b8755bd0ee23149684e83d|#

//->> EM__TARG publics

//->> zigem publish -- end of generated code
