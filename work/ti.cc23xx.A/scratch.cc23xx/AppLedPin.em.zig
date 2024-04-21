const em = @import("../../.gen/em.zig");

pub const em__unit = em.UnitSpec{
    .kind = .module,
    .upath = "scratch.cc23xx/AppLedPin",
    .self = @This(),
};

pub const Hal = em.import.@"ti.mcu.cc23xx/Hal";

pub const d_ = &em__decls;
pub var em__decls = em__unit.declare(struct {
    pin: em.Config(i16) = em.Config(i16){},
    _mask: em.Config(u32) = em.Config(u32){},
    _is_def: em.Config(bool) = em.Config(bool){},
});

pub fn em__initH() void {
    d_.pin.initH(-1);
    d_._mask.initH(0);
    d_._is_def.initH(false);
}

pub fn em__constructH() void {
    const p = d_.pin.get();
    if (p < 0) return;
    d_._is_def.set(true);
    const p5 = @as(u5, @bitCast(@as(i5, @truncate(p))));
    const m: u32 = @as(u32, 1) << p5;
    d_._mask.set(m);
}

const REG = em.REG;

const pin = d_.pin.get();
const is_def = (pin >= 0);
const mask = if (is_def) 1 << pin else 0;

pub fn clear() void {
    if (is_def) REG(Hal.GPIO_BASE + Hal.GPIO_O_DOUTCLR31_0).* = mask;
}

pub fn makeOutput() void {
    if (is_def) REG(Hal.GPIO_BASE + Hal.GPIO_O_DOESET31_0).* = mask;
    if (is_def) REG(@as(u32, Hal.IOC_BASE) + @as(u32, Hal.IOC_O_IOC0) + pin * 4).* &= ~Hal.IOC_IOC0_INPEN;
}

pub fn pinId() i16 {
    return pin;
}

pub fn set() void {
    if (is_def) REG(Hal.GPIO_BASE + Hal.GPIO_O_DOUTSET31_0).* = mask;
}

pub fn toggle() void {
    if (is_def) REG(Hal.GPIO_BASE + Hal.GPIO_O_DOUTTGL31_0).* = mask;
}
