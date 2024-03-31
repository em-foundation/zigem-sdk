const em = @import("../em.zig");
const hal = @import("../hal.zig");
const std = @import("std");

const REG = em.REG;

const Gpio = struct {
    _pin: i16,
    _mask: u32,
    pub fn clear(self: *const Gpio) void {
        REG(hal.GPIO_BASE + hal.GPIO_O_DOUTCLR31_0).* = self._mask;
    }
    pub fn functionSelect(self: *const Gpio, select: u8) void {
        const addr: u32 = hal.IOC_BASE + hal.IOC_O_IOC0;
        const pidx: u32 = @as(u16, @bitCast(self._pin));
        REG(addr + pidx * 4).* = select;
    }
    pub fn makeOutput(self: *const Gpio) void {
        REG(hal.GPIO_BASE + hal.GPIO_O_DOESET31_0).* = self._mask;
        const addr: u32 = hal.IOC_BASE + hal.IOC_O_IOC0;
        const pidx: u32 = @as(u16, @bitCast(self._pin));
        REG(addr + pidx * 4).* &= ~hal.IOC_IOC0_INPEN;
    }
    pub fn pinId(self: *const Gpio) i16 {
        return self._pin;
    }
    pub fn set(self: *const Gpio) void {
        REG(hal.GPIO_BASE + hal.GPIO_O_DOUTSET31_0).* = self._mask;
    }
    pub fn toggle(self: *const Gpio) void {
        REG(hal.GPIO_BASE + hal.GPIO_O_DOUTTGL31_0).* = self._mask;
    }
};

pub fn create(comptime pin: i16) Gpio {
    comptime {
        return std.mem.zeroInit(Gpio, .{ ._pin = pin, ._mask = 1 << pin });
    }
}
