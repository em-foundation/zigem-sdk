pub const em = @import("../../.gen/em.zig");
pub const em__U = em.module(@This(), .{
    .inherits = em.import.@"em.hal/OneShotMilliI",
});

pub const Idle = em.import.@"ti.mcu.cc23xx/Idle";
pub const IntrVec = em.import.@"em.arch.arm/IntrVec";

pub const Handler = em__U.inherits.Handler;

pub const EM__HOST = struct {
    //
    pub fn em__constructH() void {
        IntrVec.useIntrH("LGPT3_COMB");
    }
};

pub const EM__TARG = struct {
    //

    const hal = em.hal;
    const reg = em.reg;

    var cur_arg: em.ptr_t = null;
    var cur_fxn: ?em.CB(Handler) = null;

    pub fn disable() void {
        cur_fxn = null;
        Idle.setWaitOnly(false);
        hal.NVIC_DisableIRQ(hal.LGPT3_COMB_IRQn);
        reg(hal.LGPT3_BASE + hal.LGPT_O_ICLR).* = hal.LGPT_ICLR_TGT;
    }

    pub fn enable(msecs: u32, handler: em.CB(Handler), arg: em.ptr_t) void {
        cur_fxn = handler;
        cur_arg = arg;
        Idle.setWaitOnly(true);
        hal.NVIC_EnableIRQ(hal.LGPT3_COMB_IRQn);
        reg(hal.CLKCTL_BASE + hal.CLKCTL_O_CLKENSET0).* = hal.CLKCTL_CLKENSET0_LGPT3;
        reg(hal.LGPT3_BASE + hal.LGPT_O_IMSET).* = hal.LGPT_IMSET_TGT;
        reg(hal.LGPT3_BASE + hal.LGPT_O_TGT).* = msecs * (48_000_000 / 1000);
        reg(hal.LGPT3_BASE + hal.LGPT_O_CTL).* = hal.LGPT_CTL_MODE_UP_ONCE | hal.LGPT_CTL_C0RST;
    }

    export fn LGPT3_COMB_isr() void {
        if (em.hosted) return;
        const fxn = cur_fxn;
        disable();
        if (fxn != null) fxn.?(Handler{ .arg = cur_arg });
    }
};
