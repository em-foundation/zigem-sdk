pub const em = @import("../../.gen/em.zig");
pub const em__U = em.Template(@This(), .{});

pub const EM__CONFIG = struct {
    em__upath: []const u8,
    pin: em.Param(i16),
};

pub fn em__generateS(comptime name: []const u8) type {
    return struct {
        pub const em__U = em.Module(
            @This(),
            .{
                .inherits = em.import.@"em.hal/GpioI",
                .generated = true,
                .name = name,
            },
        );
        pub const em__C = @This().em__U.Config(EM__CONFIG);

        pub const EM__HOST = struct {
            //
            pub const pin = em__C.pin.ref();

            pub fn em__initH() void {
                pin.set(-1);
            }
        };

        pub const EM__TARG = struct {
            //

            const pin = em__C.pin.unwrap();
            const is_def = (pin >= 0);
            const mask = init: {
                const p5 = @as(u5, @bitCast(@as(i5, @truncate(pin))));
                const m: u32 = @as(u32, 1) << p5;
                break :init m;
            };

            const hal = em.hal;
            const reg = em.reg;

            pub fn clear() void {
                if (is_def) reg(hal.GPIO_BASE + hal.GPIO_O_DOUTCLR31_0).* = mask;
            }

            pub fn functionSelect(select: u8) void {
                const off = @as(u32, hal.IOC_O_IOC0 + @as(u16, @bitCast(pin)) * 4);
                if (is_def) reg(@as(u32, hal.IOC_BASE) + off).* = select;
            }

            pub fn makeInput() void {
                if (is_def) reg(hal.GPIO_BASE + hal.GPIO_O_DOECLR31_0).* = mask;
                const off = @as(u32, hal.IOC_O_IOC0 + @as(u16, @bitCast(pin)) * 4);
                if (is_def) reg(@as(u32, hal.IOC_BASE) + off).* |= hal.IOC_IOC0_INPEN;
            }

            pub fn makeOutput() void {
                if (is_def) reg(hal.GPIO_BASE + hal.GPIO_O_DOESET31_0).* = mask;
                const off = @as(u32, hal.IOC_O_IOC0 + @as(u16, @bitCast(pin)) * 4);
                if (is_def) reg(@as(u32, hal.IOC_BASE) + off).* &= ~hal.IOC_IOC0_INPEN;
            }

            pub fn pinId() i16 {
                return pin;
            }

            pub fn reset() void {
                if (is_def) reg(hal.GPIO_BASE + hal.GPIO_O_DOECLR31_0).* = mask;
                const off = @as(u32, hal.IOC_O_IOC0 + @as(u16, @bitCast(pin)) * 4);
                if (is_def) reg(@as(u32, hal.IOC_BASE) + off).* |= hal.IOC_IOC0_IOMODE_M | hal.IOC_IOC0_PULLCTL_M;
            }

            pub fn set() void {
                if (is_def) reg(hal.GPIO_BASE + hal.GPIO_O_DOUTSET31_0).* = mask;
            }

            pub fn toggle() void {
                if (is_def) reg(hal.GPIO_BASE + hal.GPIO_O_DOUTTGL31_0).* = mask;
            }
        };
    };
}
