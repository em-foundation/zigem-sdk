pub const em = @import("../../.gen/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const BusyWait = em.import.@"ti.mcu.cc23xx/BusyWait";

pub const EM__CONFIG = struct {
    CS: em.Proxy(em.import.@"em.hal/GpioI"),
    CLK: em.Proxy(em.import.@"em.hal/GpioI"),
    PICO: em.Proxy(em.import.@"em.hal/GpioI"),
    POCI: em.Proxy(em.import.@"em.hal/GpioI"),
};

pub const EM__HOST = struct {
    pub const CS = em__C.CS.ref();
    pub const CLK = em__C.CLK.ref();
    pub const PICO = em__C.PICO.ref();
    pub const POCI = em__C.POCI.ref();
};

pub const EM__TARG = struct {
    //
    const CS = em__C.CS.unwrap();
    const CLK = em__C.CLK.unwrap();
    const PICO = em__C.PICO.unwrap();
    const POCI = em__C.POCI.unwrap();

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
