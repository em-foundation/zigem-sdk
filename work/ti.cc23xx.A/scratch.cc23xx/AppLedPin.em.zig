const em = @import("../../.gen/em.zig");

pub const em__unit = em.UnitSpec{
    .kind = .module,
    .upath = "scratch.cc23xx/AppLedPin",
    .self = @This(),
};

pub const Hal = em.import.@"ti.mcu.cc23xx/Hal";

pub const d_ = &em__decls;
pub var em__decls = em__unit.declare(struct {
    pin: em.Config(i16) = em.Config(i16).initV(-1),
    _mask: em.Config(u32) = em.Config(u32).initV(0),
    _is_def: em.Config(bool) = em.Config(bool).initV(false),
});

pub fn em__constructH() void {
    const pin = d_.pin.get();
    if (pin < 0) return;
    d_._is_def.set(true);
    const p5 = @as(u5, @bitCast(@as(i5, @truncate(pin))));
    const mask: u32 = @as(u32, 1) << p5;
    d_._mask.set(mask);
}

const REG = em.REG;

pub fn clear() void {
    if (d_._is_def.get()) {
        REG(Hal.GPIO_BASE + Hal.GPIO_O_DOUTCLR31_0).* = d_._mask.get();
    }
}

pub fn makeOutput() void {
    if (d_._is_def.get()) {
        REG(Hal.GPIO_BASE + Hal.GPIO_O_DOESET31_0).* = d_._mask.get();
        REG(@as(u32, Hal.IOC_BASE) + @as(u32, Hal.IOC_O_IOC0) + d_._mask.get() * 4).* &= ~Hal.IOC_IOC0_INPEN;
    }
}

pub fn pinId() i16 {
    return d_.pin.get();
}

pub fn set() void {
    if (d_._is_def.get()) {
        REG(Hal.GPIO_BASE + Hal.GPIO_O_DOUTSET31_0).* = d_._mask.get();
    }
}

pub fn toggle() void {
    if (d_._is_def.get()) {
        REG(Hal.GPIO_BASE + Hal.GPIO_O_DOUTTGL31_0).* = d_._mask.get();
    }
}
