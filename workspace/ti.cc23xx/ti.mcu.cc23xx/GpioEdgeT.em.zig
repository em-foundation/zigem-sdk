pub const em = @import("../../zigem/em.zig");
pub const em__T = em.template(@This(), .{});

pub const EM__CONFIG = struct {
    em__upath: []const u8,
    Pin: em.Proxy(em.import.@"em.hal/GpioI"),
    pin: em.Param(i16),
};

pub fn em__generateS(comptime name: []const u8) type {
    return struct {
        pub const em__U = em.module(
            @This(),
            .{
                .inherits = GpioEdgeI,
                .generated = true,
                .name = name,
            },
        );
        pub const em__C = em__U.config(EM__CONFIG);

        pub const Aux = em.import.@"ti.mcu.cc23xx/GpioEdgeAux";
        pub const GpioEdgeI = em.import.@"em.hal/GpioEdgeI";
        pub const Pin = em__U.Generate("Pin", em.import.@"ti.mcu.cc23xx/GpioT");

        pub const HandlerArg = GpioEdgeI.HandlerArg;
        pub const HandlerFxn = GpioEdgeI.HandlerFxn;

        fn mkMask(pin: i16) u32 {
            const p5 = @as(u5, @bitCast(@as(i5, @truncate(pin))));
            const m: u32 = @as(u32, 1) << p5;
            return m;
        }

        pub const EM_META = struct {
            //
            pub const pin = em__C.pin;

            pub fn em__initH() void {
                pin.set(-1);
            }

            pub fn em__constructH() void {
                Pin.pin.set(em__C.pin.get());
            }

            pub fn setDetectHandlerH(h: HandlerFxn) void {
                Aux.addHandlerInfoH(.{ .handler = h, .mask = mkMask(em__C.pin.get()) });
            }
        };

        pub const EM__TARG = struct {
            //
            const pin = em__C.pin;
            const is_def = (pin >= 0);
            const mask = mkMask(pin);
            const off = @as(u32, hal.IOC_O_IOC0 + @as(u16, @bitCast(pin)) * 4);

            const hal = em.hal;
            const reg = em.reg;

            pub fn clearDetect() void {
                if (is_def) reg(hal.GPIO_BASE + hal.GPIO_O_ICLR).* = mask;
            }

            pub fn disableDetect() void {
                if (is_def) reg(hal.GPIO_BASE + hal.GPIO_O_IMCLR).* = mask;
                if (is_def) reg(hal.IOC_BASE + off).* &= ~hal.IOC_IOC0_WUENSB;
            }

            pub fn enableDetect() void {
                if (is_def) reg(hal.GPIO_BASE + hal.GPIO_O_IMSET).* = mask;
                if (is_def) reg(hal.IOC_BASE + off).* |= hal.IOC_IOC0_WUENSB;
            }

            pub fn setDetectFallingEdge() void {
                if (is_def) reg(hal.IOC_BASE + off).* &= ~hal.IOC_IOC0_EDGEDET_M;
                if (is_def) reg(hal.IOC_BASE + off).* |= hal.IOC_IOC0_EDGEDET_EDGE_NEG;
            }

            pub fn setDetectRisingEdge() void {
                if (is_def) reg(hal.IOC_BASE + off).* &= ~hal.IOC_IOC0_EDGEDET_M;
                if (is_def) reg(hal.IOC_BASE + off).* |= hal.IOC_IOC0_EDGEDET_EDGE_POS;
            }

            // GpioI delegates

            pub fn clear() void {
                Pin.clear();
            }

            pub fn functionSelect(select: u8) void {
                Pin.functionSelect(select);
            }

            pub fn get() bool {
                return Pin.get();
            }

            pub fn isInput() bool {
                return Pin.isInput();
            }

            pub fn isOutput() bool {
                return Pin.isOutput();
            }

            pub fn makeInput() void {
                Pin.makeInput();
            }

            pub fn makeOutput() void {
                Pin.makeOutput();
            }

            pub fn pinId() i16 {
                return pin;
            }

            pub fn reset() void {
                Pin.reset();
            }

            pub fn set() void {
                Pin.set();
            }

            pub fn setInternalPullup(enable: bool) void {
                Pin.setInternalPullup(enable);
            }

            pub fn toggle() void {
                Pin.toggle();
            }
        };
    };
}
