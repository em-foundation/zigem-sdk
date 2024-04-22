const em = @import("../../.gen/em.zig");

pub const em__unit = em.UnitSpec{
    .kind = .module,
    .upath = "scratch.cc23xx/AppLedPin",
    .self = @This(),
};

pub const Hal = em.import.@"ti.mcu.cc23xx/Hal";

pub var c_pin = em__unit.declareConfig("pin", i16){};

pub var _is_def = em__unit.declareConfig("_is_def", bool){};
pub var _mask = em__unit.declareConfig("_mask", u32){};

pub fn em__initH() void {
    c_pin.initH(-1);
    _mask.initH(0);
    _is_def.initH(false);
}

pub fn em__constructH() void {
    const p = c_pin.get();
    if (p < 0) return;
    _is_def.set(true);
    const p5 = @as(u5, @bitCast(@as(i5, @truncate(p))));
    const m: u32 = @as(u32, 1) << p5;
    _mask.set(m);
}

const REG = em.REG;

const pin = c_pin.unwrap();
const is_def = _is_def.unwrap();
const mask = _mask.unwrap();

pub fn clear() void {
    if (is_def) REG(Hal.GPIO_BASE + Hal.GPIO_O_DOUTCLR31_0).* = mask;
}

pub fn makeOutput() void {
    if (is_def) REG(Hal.GPIO_BASE + Hal.GPIO_O_DOESET31_0).* = mask;
    const off = @as(u32, Hal.IOC_O_IOC0 + @as(u16, @bitCast(pin)) * 4);
    if (is_def) REG(@as(u32, Hal.IOC_BASE) + off).* &= ~Hal.IOC_IOC0_INPEN;
}

pub fn pinId() i16 {
    return c_pin.get();
}

pub fn set() void {
    if (is_def) REG(Hal.GPIO_BASE + Hal.GPIO_O_DOUTSET31_0).* = mask;
}

pub fn toggle() void {
    if (is_def) REG(Hal.GPIO_BASE + Hal.GPIO_O_DOUTTGL31_0).* = mask;
}
