pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const x_Uptimer = em__unit.proxy("Uptimer", em.Import.@"em.hal/UptimerI");

pub const EM__HOST = struct {
    //
};

pub const EM__TARG = struct {
    //
    const Uptimer = x_Uptimer.unwrap();

    pub fn getCurrent(o_subs: *u32) u32 {
        const time = Uptimer.read();
        o_subs.* = time.subs;
        return time.secs;
    }
};
