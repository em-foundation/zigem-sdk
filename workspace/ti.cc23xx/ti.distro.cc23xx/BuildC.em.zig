pub const em = @import("../../zigem/em.zig");
pub const em__U = em.composite(@This(), .{});

pub const BoardC = em.import.@"em__distro/BoardC";
pub const IntrVec = em.import.@"em.arch.arm/IntrVec";
pub const LinkerC = em.import.@"em__distro/LinkerC";
pub const StartupC = em.import.@"em.arch.arm/StartupC";

pub fn em__configureM() void {
    const nvic_intrs = [_][]const u8{
        "CPUIRQ0",
        "CPUIRQ1",
        "CPUIRQ2",
        "CPUIRQ3",
        "CPUIRQ4",
        "GPIO_COMB",
        "LRFD_IRQ0",
        "LRFD_IRQ1",
        "DMA_DONE_COMB",
        "AES_COMB",
        "SPI0_COMB",
        "UART0_COMB",
        "I2C0_IRQ",
        "LGPT0_COMB",
        "LGPT1_COMB",
        "ADC0_COMB",
        "CPUIRQ16",
        "LGPT2_COMB",
        "LGPT3_COMB",
    };
    for (nvic_intrs) |n| {
        IntrVec.addIntrM(n);
    }
    //
    em.setUsed(BoardC);
    em.setUsed(IntrVec);
    em.setUsed(LinkerC);
    em.setUsed(StartupC);
}

//#region zigem

//->> zigem publish #|f259f4ef1e8dd3593ca2c27278a0783d58c7a02b9235422a2ec707e2c6db5604|#

//->> zigem publish -- end of generated code

//#endregion zigem
