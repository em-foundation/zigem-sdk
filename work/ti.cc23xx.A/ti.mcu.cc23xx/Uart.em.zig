const std = @import("std");

const em = @import("../../.gen/em.zig");
const me = @This();

const Hal = em.Unit.@"ti.mcu.cc23xx/Hal";

pub const em__unit = em.UnitSpec{
    .kind = .module,
    .upath = "ti.mcu.cc23xx/Uart",
    .self = me,
    .imports = &[_]em.UnitSpec{
        Hal.em__unit,
    },
};
