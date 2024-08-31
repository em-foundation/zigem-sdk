pub const em = @import("../../build/.gen/em.zig");
pub const em__U = em.module(@This(), .{});

pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const Common = em.import.@"em.mcu/Common";
pub const RadioDriver = em.import.@"ti.radio.cc23xx/RadioDriver";

pub const EM__HOST = struct {};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    pub fn em__run() void {
        RadioDriver.setup(.CW);
        RadioDriver.startCw();
    }
};
