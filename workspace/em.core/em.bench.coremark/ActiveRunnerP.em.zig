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
        const us = Common.UsCounter.stop(null);
        em.print("{d} iterations, usecs = {d}\n", .{ ITERATIONS, us });
        em.print("list crc = {x:0>4}\n", .{Utils.getCrc(.LIST)});
        em.print("matrix crc = {x:0>4}\n", .{Utils.getCrc(.MATRIX)});
        em.print("state crc = {x:0>4}\n", .{Utils.getCrc(.STATE)});
        em.print("final crc = {x:0>4}\n", .{Utils.getCrc(.FINAL)});
    }
};

//#region zigem

//->> zigem publish #|66d5e165b12a38a90b3466f8cda5a640c2985ee56a370012e47cde8c1c688de1|#

//->> EM__TARG publics

//->> zigem publish -- end of generated code

//#endregion zigem
