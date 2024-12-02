pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{ .inherits = BusyWaitI });

pub const BusyWaitI = em.import.@"em.hal/BusyWaitI";

pub const UsCounter = em.import.@"em.arch.arm/UsCounterSystick";

pub const EM__TARG = struct {
    //
    pub fn wait(usecs: u32) void {
        UsCounter.set(usecs);
        UsCounter.spin();
    }
};

//#region zigem

//->> zigem publish #|abd32b29a9e024f865184a74bc0b131a0b362a2dabf9548b935632e65212d1a7|#

//->> EM__TARG publics
pub const wait = EM__TARG.wait;

//->> zigem publish -- end of generated code

//#endregion zigem
