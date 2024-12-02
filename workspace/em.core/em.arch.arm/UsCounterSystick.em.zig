pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{
    .inherits = UsCounterI,
});

pub const UsCounterI = em.import.@"em.hal/UsCounterI";

pub const EM__TARG = struct {
    //
    const hal = em.hal;

    const MAX: u32 = 0x00FFFFFF;
    const MHZ: u32 = 48;

    var thresh: u32 = undefined;

    pub fn set(time_us: u32) void {
        thresh = MAX - (time_us * MHZ);
        EM__TARG.start();
    }

    pub fn spin() void {
        var val: u32 = MAX;
        const vp: *volatile u32 = &val;
        while (val > thresh) {
            vp.* = hal.SysTick.*.VAL;
        }
        hal.SysTick.*.CTRL = 0;
    }

    pub fn start() void {
        hal.SysTick.*.CTRL = (1 << hal.SysTick_CTRL_CLKSOURCE_Pos) | (1 << hal.SysTick_CTRL_ENABLE_Pos);
        hal.SysTick.*.LOAD = MAX;
        hal.SysTick.*.VAL = 0;
    }

    pub fn stop(o_raw: ?*u32) u32 {
        const lr = hal.SysTick.*.LOAD;
        const vr = hal.SysTick.*.VAL;
        const raw = lr - vr;
        if (o_raw != null) o_raw.?.* = raw;
        const dt = (((raw) << 1) / 48) >> 1;
        hal.SysTick.*.CTRL = 0;
        return dt;
    }
};

//#region zigem

//->> zigem publish #|062779848b7e38736fe5a3fddc76760d88192a6a36b4197a34756eccccda2e96|#

//->> EM__TARG publics
pub const set = EM__TARG.set;
pub const spin = EM__TARG.spin;
pub const start = EM__TARG.start;
pub const stop = EM__TARG.stop;

//->> zigem publish -- end of generated code

//#endregion zigem
