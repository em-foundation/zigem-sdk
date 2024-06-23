pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const BusyWait = em.Import.@"ti.mcu.cc23xx/BusyWait";

pub const x_CS = em__unit.proxy("CS", em.Import.@"em.hal/GpioI");
pub const x_CLK = em__unit.proxy("CLK", em.Import.@"em.hal/GpioI");
pub const x_PICO = em__unit.proxy("PICO", em.Import.@"em.hal/GpioI");
pub const x_POCI = em__unit.proxy("POCI", em.Import.@"em.hal/GpioI");

pub const EM__HOST = struct {};

pub const EM__TARG = struct {
    //
    const CS = x_CS.unwrap();
    const CLK = x_CLK.unwrap();
    const PICO = x_PICO.unwrap();
    const POCI = x_POCI.unwrap();

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
