pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const CoreBench = em.Import.@"em.coremark/CoreBench";
pub const Utils = em.Import.@"em.coremark/Utils";

pub const c_ITERATIONS = em__unit.config("ITERATIONS", u16);

pub const EM__HOST = struct {
    //
    pub fn em__initH() void {
        c_ITERATIONS.init(10);
    }
};

pub const EM__TARG = struct {
    //
    const ITERATIONS = c_ITERATIONS.unwrap();

    pub fn em__startup() void {
        CoreBench.setup();
    }

    pub fn em__run() void {
        em.@"%%[d+]"();
        for (0..ITERATIONS) |_| {
            _ = CoreBench.run(0);
        }
        em.@"%%[d-]"();
    }
};
