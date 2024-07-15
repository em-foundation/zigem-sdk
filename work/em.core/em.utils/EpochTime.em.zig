pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});
pub const em__C = em__unit.Config(EM__CONFIG);

pub const EM__CONFIG = struct {
    Uptimer: em.Proxy(em.Import.@"em.hal/UptimerI"),
};

pub const EM__HOST = struct {
    pub const Uptimer = em__C.Uptimer.ref();
};

pub const EM__TARG = struct {
    //
    const Uptimer = em__C.Uptimer.unwrap();

    pub fn getCurrent(o_subs: *u32) u32 {
        const time = Uptimer.read();
        o_subs.* = time.subs;
        return time.secs;
    }
};
