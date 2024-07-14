pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const Common = em.Import.@"em.mcu/Common";
pub const CoreBench = em.Import.@"em.coremark/CoreBench";
pub const Utils = em.Import.@"em.coremark/Utils";

pub const ITERATIONS: u16 = 10;

pub const EM__HOST = struct {};

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
