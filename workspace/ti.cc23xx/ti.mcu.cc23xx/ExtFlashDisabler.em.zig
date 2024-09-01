pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    CS: em.Proxy(em.import.@"em.hal/GpioI"),
    CLK: em.Proxy(em.import.@"em.hal/GpioI"),
    PICO: em.Proxy(em.import.@"em.hal/GpioI"),
    POCI: em.Proxy(em.import.@"em.hal/GpioI"),
};

pub const BusyWait = em.import.@"ti.mcu.cc23xx/BusyWait";

pub const EM__HOST = struct {
    pub const CS = em__C.CS;
    pub const CLK = em__C.CLK;
    pub const PICO = em__C.PICO;
    pub const POCI = em__C.POCI;
};

pub const EM__TARG = struct {
    //
    const CS = em__C.CS.scope();
    const CLK = em__C.CLK.scope();
    const PICO = em__C.PICO.scope();
    const POCI = em__C.POCI.scope();

    const SD_CMD: u8 = 0xb9;

    pub fn em__startup() void {
        em.@"%%[c+]"();
        CS.makeOutput();
        CLK.makeOutput();
        PICO.makeOutput();
        POCI.makeInput();
        // attention
        CS.set();
        BusyWait.wait(1);
        CS.clear();
        BusyWait.wait(1);
        CS.set();
        BusyWait.wait(50);
        // shutdown command
        CS.clear();
        for (0..8) |i| {
            CLK.clear();
            const bi = em.@"<>"(u3, i);
            const bv = (SD_CMD >> (7 - bi)) & 0x01;
            if (bv == 0) {
                PICO.clear();
            } else {
                PICO.set();
            }
            CLK.set();
            BusyWait.wait(1);
        }
        CLK.clear();
        CS.set();
        BusyWait.wait(50);
        //
        CS.reset();
        CLK.reset();
        PICO.reset();
        POCI.reset();
        em.@"%%[c-]"();
    }
};
