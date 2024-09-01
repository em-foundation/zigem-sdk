pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{
    .inherits = em.import.@"em.hal/MsCounterI",
});

pub const EM__HOST = struct {
    //
};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    pub fn start() void {
        reg(hal.CLKCTL_BASE + hal.CLKCTL_O_CLKENSET0).* = hal.CLKCTL_CLKENSET0_LGPT3;
        reg(hal.LGPT3_BASE + hal.LGPT_O_IMSET).* = hal.LGPT_IMSET_TGT;
        reg(hal.LGPT3_BASE + hal.LGPT_O_TGT).* = 0xffffff;
        reg(hal.LGPT3_BASE + hal.LGPT_O_CTL).* = hal.LGPT_CTL_MODE_UP_ONCE | hal.LGPT_CTL_C0RST;
    }

    pub fn stop() u32 {
        const dt: u32 = reg(hal.LGPT3_BASE + hal.LGPT_O_CNTR).* / (48_000_000 / 1000);
        reg(hal.CLKCTL_BASE + hal.CLKCTL_O_CLKENCLR0).* = hal.CLKCTL_CLKENSET0_LGPT3;
        return dt;
    }
};
