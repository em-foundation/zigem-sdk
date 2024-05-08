pub const EM__SPEC = null;

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{
    .inherits = em.Import.@"em.hal/OneShotMilliI",
});

pub const IntrVec = em.Import.@"em.arch.arm/IntrVec";

pub const EM__HOST = null;

pub fn em__configureH() void {
    IntrVec.useIntrH("LGPT3_COMB");
}

pub const EM__TARG = null;

const hal = em.hal;
const reg = em.reg;

var cur_arg: em.ptr_t = null;
var cur_fxn: ?Handler = null;

pub const Handler = *const fn (arg: em.ptr_t) void;

pub fn disable() void {
    cur_fxn = null;
    hal.NVIC_DisableIRQ(hal.LGPT3_COMB_IRQn);
    reg(hal.LGPT3_BASE + hal.LGPT_O_ICLR).* = hal.LGPT_ICLR_TGT;
}

pub fn enable(msecs: u32, handler: Handler, arg: em.ptr_t) void {
    cur_fxn = handler;
    cur_arg = arg;
    hal.NVIC_EnableIRQ(hal.LGPT3_COMB_IRQn);
    reg(hal.CLKCTL_BASE + hal.CLKCTL_O_CLKENSET0).* = hal.CLKCTL_CLKENSET0_LGPT3;
    reg(hal.LGPT3_BASE + hal.LGPT_O_IMSET).* = hal.LGPT_IMSET_TGT;
    reg(hal.LGPT3_BASE + hal.LGPT_O_TGT).* = msecs * (48_000_000 / 1000);
    reg(hal.LGPT3_BASE + hal.LGPT_O_CTL).* = hal.LGPT_CTL_MODE_UP_ONCE | hal.LGPT_CTL_C0RST;
}

export fn LGPT3_COMB_isr() void {
    const fxn = cur_fxn;
    disable();
    if (fxn != null) fxn.?(cur_arg);
}

//from ti.mcu.cc23xx import Mcu
//
//from em.arch.arm import InterruptT { name: "LGPT3_COMB" } as Intr
//
//from em.hal import OneShotMilliI
//
//module OneShotMilli: OneShotMilliI
//
//private:
//
//    var curArg: ptr_t
//    var curFxn: Handler
//
//    function isr: Intr.Handler
//
//end
//
//def em$construct()
//    Intr.setHandlerH(isr)
//end
//
//def disable()
//    curFxn = null
//    Intr.disable()
//    ^^HWREG(LGPT3_BASE + LGPT_O_ICLR) = LGPT_ICLR_TGT^^
//end
//
//def enable(msecs, handler, arg)
//    curFxn = handler
//    curArg = arg
//    Intr.enable()
//    ^^HWREG(CLKCTL_BASE + CLKCTL_O_CLKENSET0)^^ = ^CLKCTL_CLKENSET0_LGPT3
//    ^^HWREG(LGPT3_BASE + LGPT_O_IMSET) = LGPT_IMSET_TGT^^
//    ^^HWREG(LGPT3_BASE + LGPT_O_TGT)^^ = msecs * (Mcu.mclkFrequency / 1000)
//    ^^HWREG(LGPT3_BASE + LGPT_O_CTL) = LGPT_CTL_MODE_UP_ONCE | LGPT_CTL_C0RST^^
//end
//
//def isr()
//    auto fxn = curFxn
//    disable()
//    fxn(curArg) if fxn
//end
//
//
