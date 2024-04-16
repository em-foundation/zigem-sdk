const em = @import("../../.gen/em.zig");

const Hal = em.Unit.@"ti.mcu.cc23xx/Hal";

pub const em__unit = em.UnitSpec{
    .kind = .module,
    .upath = "ti.mcu.cc23xx/Uart",
    .self = @This(),
    .imports = &[_]em.UnitSpec{
        Hal.em__unit,
    },
};
