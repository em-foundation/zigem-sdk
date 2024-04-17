const em = @import("../../.gen/em.zig");

pub const em__unit = em.UnitSpec{
    .kind = .module,
    .upath = "gist.cc23xx/Test01",
    .self = @This(),
};

pub const LinkerC = em.import.@"em.build.misc/LinkerC";

pub const BusyWait = em.import.@"ti.mcu.cc23xx/BusyWait";
pub const Hal = em.import.@"ti.mcu.cc23xx/Hal";
pub const Uart = em.import.@"ti.mcu.cc23xx/Uart";

pub const d_ = &em__decls;
pub var em__decls = em__unit.declare(struct {
    max: em.Config(u32) = em.Config(u32).initV(20),
    min: em.Config(u32) = em.Config(u32).initV(10),
});

pub fn em__initH() void {
    em.print("hosted = {any}", .{em.hosted});
    d_.max.set(40);
}

pub fn em__run() void {
    //c.max.set(20);
    em.REG(1111).* = d_.max.get();
}
