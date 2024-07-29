pub const em = @import("../../.gen/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {};

pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const Common = em.import.@"em.mcu/Common";
pub const RadioDriver = em.import.@"ti.radio.cc23xx/RadioDriver";

pub const EM__HOST = struct {};

pub const EM__TARG = struct {
    //
    var data = [_]u32{ 0x0203000F, 0x000A0001, 0x04030201, 0x08070605, 0x00000A09 };

    pub fn em__run() void {
        Common.GlobalInterrupts.enable();
        RadioDriver.setup(.TX);
        RadioDriver.startTx(data[0..]);
    }
};
