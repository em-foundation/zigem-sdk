pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    Uptimer: em.Proxy(em.import.@"em.hal/UptimerI"),
};

pub const EM__META = struct {
    pub const Uptimer = em__C.Uptimer;
};

pub const EM__TARG = struct {
    //
    const Uptimer = em__C.Uptimer.scope();

    pub fn getRawTime(o_subs: *u32) u32 {
        const time = Uptimer.read();
        o_subs.* = time.subs;
        return time.secs;
    }

    pub fn msecsFromSubs(subs: u32) u32 {
        return ((subs >> 24) * 1000) / 256;
    }
};
