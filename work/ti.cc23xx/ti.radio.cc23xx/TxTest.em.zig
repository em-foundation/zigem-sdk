pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const AppLed = em.Import.@"em__distro/BoardC".AppLed;
pub const Common = em.Import.@"em.mcu/Common";
pub const RadioDriver = em.Import.@"ti.radio.cc23xx/RadioDriver";

pub const EM__HOST = struct {};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    var data = [_]u32{ 0x0203000F, 0x000A0001, 0x04030201, 0x08070605, 0x00000009 };

    pub fn em__run() void {
        RadioDriver.setup(.TX);
        RadioDriver.startTx(data[0..]);
    }
};
