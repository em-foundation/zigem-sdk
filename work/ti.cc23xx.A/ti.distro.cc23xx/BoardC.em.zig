const em = @import("../../.gen/em.zig");

pub const em__unit = em.Unit{
    .kind = .composite,
    .upath = "ti.distro.cc23xx/BoardC",
    .self = @This(),
};

pub const Hal = em.import.@"ti.mcu.cc23xx/Hal";

pub const LinkerC = em.import.@"em.build.misc/LinkerC";
pub const StartupC = em.import.@"em.arch.arm/StartupC";
