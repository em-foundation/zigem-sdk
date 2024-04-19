const em = @import("../../.gen/em.zig");

pub const BoardC = em.import.em__distro.BoardC;

pub const BusyWait = em.import.@"scratch.cc23xx".BusyWait;

pub const em__unit = em.UnitSpec{
    .kind = .module,
    .upath = "gist.cc23xx/Gist01_Busy",
    .self = @This(),
};

const Hal: type = BoardC.Hal;
const REG = em.REG;

pub fn em__run() void {
    const pin = 15;
    const mask = (1 << pin);
    REG(Hal.GPIO_BASE + Hal.GPIO_O_DOESET31_0).* = mask;
    REG(Hal.IOC_BASE + Hal.IOC_O_IOC0 + pin * 4).* &= ~Hal.IOC_IOC0_INPEN;
    for (0..10) |_| {
        BusyWait.wait(100000);
        REG(Hal.GPIO_BASE + Hal.GPIO_O_DOUTTGL31_0).* = mask;
    }
}
