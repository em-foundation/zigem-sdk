pub const EM__SPEC = {};

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Composite(@This(), .{});

pub const Hal = em.Import.@"ti.mcu.cc23xx/Hal";

pub const LinkerC = em.Import.@"em.build.misc/LinkerC";
pub const StartupC = em.Import.@"em.arch.arm/StartupC";

pub const EM__HOST = {};
