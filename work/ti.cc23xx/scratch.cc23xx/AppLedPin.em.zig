pub const EM__SPEC = {};

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const Hal = em.Import.@"ti.mcu.cc23xx/Hal";

pub const c_pin = em__unit.Config("pin", i16);

pub const EM__HOST = {};

pub fn em__initH() void {
    c_pin.init(-1);
}

pub const EM__TARG = {};

const REG = em.REG;

const pin = c_pin.unwrap();
const is_def = (pin >= 0);
const mask = init: {
    const p5 = @as(u5, @bitCast(@as(i5, @truncate(pin))));
    const m: u32 = @as(u32, 1) << p5;
    break :init m;
};

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
