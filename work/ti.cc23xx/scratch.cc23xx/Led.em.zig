pub const EM__SPEC = null;

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const c_active_low = em__unit.Config("active_low", bool);
pub const x_Pin = em__unit.Proxy("Pin", em.Import.@"em.hal/GpioI");

pub const EM__HOST = null;

pub fn em__initH() void {
    c_active_low.init(false);
}

pub const EM__TARG = null;

const active_low = c_active_low.unwrap();
const Pin = x_Pin.unwrap();

pub fn em__startup() void {
    Pin.makeOutput();
    off();
}

pub fn off() void {
    if (active_low) Pin.set() else Pin.clear();
}

pub fn on() void {
    if (active_low) Pin.clear() else Pin.set();
}

pub fn toggle() void {
    Pin.toggle();
}
