const em = @import("../../.gen/em.zig");

pub const em__unit = em.UnitSpec{
    .kind = .module,
    .upath = "gist.cc23xx/Test01",
    .self = @This(),
};

pub const BoardC = em.import.em__distro.BoardC;

pub const BusyWait = em.import.@"ti.mcu.cc23xx".BusyWait;
pub const Hal = em.import.@"ti.mcu.cc23xx".Hal;
pub const Uart = em.import.@"ti.mcu.cc23xx".Uart;

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
    const REG = em.REG;
    const pin = 15;
    const mask = (1 << pin);
    REG(Hal.GPIO_BASE + Hal.GPIO_O_DOESET31_0).* = mask;
    REG(Hal.IOC_BASE + Hal.IOC_O_IOC0 + pin * 4).* &= ~Hal.IOC_IOC0_INPEN;
    for (0..10) |_| {
        BusyWait.wait(100000);
        REG(Hal.GPIO_BASE + Hal.GPIO_O_DOUTTGL31_0).* = mask;
    }
}
