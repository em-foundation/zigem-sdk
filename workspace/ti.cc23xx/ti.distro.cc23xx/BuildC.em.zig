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
    em.used(BoardC);
    em.used(IntrVec);
    em.used(LinkerC);
    em.used(StartupC);
}

//#region zigem

//->> zigem publish #|cdcebc2181313e86e0f4d2eadb5da00d4a54d339bc0da6947ddff5e164029e92|#

//->> zigem publish -- end of generated code

//#endregion zigem
