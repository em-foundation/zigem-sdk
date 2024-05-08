pub const EM__SPEC = null;

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const Common = em.Import.@"em.mcu/Common";
pub const OneShotMilli = em.Import.@"scratch.cc23xx/OneShotMilli";

pub const EM__HOST = null;

pub const EM__TARG = null;

pub fn em__run() void {
    Common.GlobalInterrupts.enable();
    OneShotMilli.enable(100, handler, null);
    em.@"%%[d+]"();
    Common.Idle.exec();
}

fn handler(_: em.ptr_t) void {
    em.@"%%[d-]"();
}
