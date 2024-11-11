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


//->> zigem publish #|535fadd7e9e00e3f80a0d95623ac2a05b52f54a2c4cc3d0a8f7278a3384aeab1|#

//->> EM__TARG publics
pub const wait = EM__TARG.wait;

//->> zigem publish -- end of generated code
