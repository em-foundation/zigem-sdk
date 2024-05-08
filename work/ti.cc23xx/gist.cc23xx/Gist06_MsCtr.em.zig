pub const EM__SPEC = null;

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const Common = em.Import.@"em.mcu/Common";
pub const MsCounter = em.Import.@"scratch.cc23xx/MsCounter";

pub const EM__HOST = null;

pub const EM__TARG = null;

pub fn em__run() void {
    MsCounter.start();
    em.@"%%[d+]"();
    Common.BusyWait.wait(100_000);
    em.@"%%[d-]"();
    const dt = MsCounter.stop();
    em.@"%%[>]"(dt);
}
