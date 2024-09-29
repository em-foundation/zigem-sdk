pub const em = @import("../../zigem/em.zig");
pub const em__T = em.template(@This(), .{});

pub const EM__CONFIG = struct {
    em__upath: []const u8,
    Pin: em.Proxy(GpioI),
    active_low: em.Param(bool),
};

pub const GpioI = em.import2.@"em.hal/GpioI";

pub fn em__generateS(comptime name: []const u8) type {
    return struct {
        //
        pub const em__U = em.module(@This(), .{
            .inherits = LedI,
            .generated = true,
            .name = name,
        });
        pub const em__C = em__U.config(EM__CONFIG);

        pub const c_active_low = em__C.active_low;
        pub const x_Pin = em__C.Pin;

        pub const LedI = em.import2.@"em.hal/LedI";
        pub const Poller = em.import2.@"em.mcu/Poller";

        // -------- META --------

        pub fn em__initH() void {
            em__C.active_low.set(false);
        }

        // -------- TARG --------

        const active_low = em__C.active_low.get();
        const Pin = if (em.IS_META) .{} else em__C.Pin.get(); // TODO Pin.default()

        pub fn em__startup() void {
            if (em.IS_META) return;
            Pin.makeOutput();
            off();
        }

        pub fn off() void {
            if (em.IS_META) return;
            if (active_low) Pin.set() else Pin.clear();
        }

        pub fn on() void {
            if (em.IS_META) return;
            if (active_low) Pin.clear() else Pin.set();
        }

        pub fn toggle() void {
            if (em.IS_META) return;
            Pin.toggle();
        }

        pub fn wink(msecs: u32) void {
            if (em.IS_META) return;
            on();
            Poller.pause(msecs);
            off();
        }
    };
}
