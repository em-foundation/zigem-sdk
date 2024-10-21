pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const Common = em.import.@"em.mcu/Common";

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    const RXF_UNWRAPPED_BASE_ADDR: u32 = 0x40093000;
    const TXF_UNWRAPPED_BASE_ADDR: u32 = 0x40093800;

    pub fn prepare() void {
        // RX fifo
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCMD).* = hal.LRFDPBE_FCMD_DATA_RXFIFO_RESET >> hal.LRFDPBE_FCMD_DATA_S;
        var rxcfg = reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG0).*;
        rxcfg &= ~(em.@"<>"(u32, (hal.LRFDPBE_FCFG0_RXADEAL_M | hal.LRFDPBE_FCFG0_RXACOM_M)));
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG0).* = rxcfg;
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_FIFOCMDADD).* = ((hal.LRFDPBE_BASE + hal.LRFDPBE_O_FSTAT) & 0x0FFF) >> 2;
        _ = em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_FIFOCMDADD).*;
        _ = em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_FIFOCMDADD).*;
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_RXFSRP).* = 0;
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_FIFOCMDADD).* = ((hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCMD) & 0x0FFF) >> 2;
        writeFifoPtr(reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_RXFRP).*, (hal.LRFDPBE_BASE + hal.LRFDPBE_O_RXFSRP));

        // TX fifo
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCMD).* = (hal.LRFDPBE_FCMD_DATA_TXFIFO_RESET >> hal.LRFDPBE_FCMD_DATA_S);
        var txcfg = reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG0).*;
        txcfg &= ~em.@"<>"(u32, hal.LRFDPBE_FCFG0_TXADEAL_M);
        txcfg |= hal.LRFDPBE_FCFG0_TXACOM_M;
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG0).* = txcfg;
    }

    pub fn write(data: []const u32) void {
        const fifoStart = ((reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG1).* & hal.LRFDPBE_FCFG1_TXSTRT_M) >> hal.LRFDPBE_FCFG1_TXSTRT_S) << 2;
        const writePointer = reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_TXFWP).* & ~em.@"<>"(u32, 0x0003);
        var fifoWritePtr: [*]volatile u32 = @ptrFromInt(TXF_UNWRAPPED_BASE_ADDR + fifoStart + writePointer);
        for (data) |d| {
            fifoWritePtr[0] = d;
            fifoWritePtr += 1;
        }
        var index = writePointer + (data.len * 4);
        const fifosz = ((reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG2).* & hal.LRFDPBE_FCFG2_TXSIZE_M) >> hal.LRFDPBE_FCFG2_TXSIZE_S) << 2;
        if (index >= fifosz) index -= fifosz;
        writeFifoPtr(index, (hal.LRFDPBE_BASE + hal.LRFDPBE_O_TXFWP));
    }

    fn writeFifoPtr(value: u32, regAddr: u32) void {
        const key = Common.GlobalInterrupts.disable();
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_FIFOCMDADD).* = em.@"<>"(u16, ((hal.LRFDPBE_BASE + hal.LRFDPBE_O_FSTAT) & 0x0FFF) >> 2);
        // delay
        _ = em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_FIFOCMDADD).*;
        _ = em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_FIFOCMDADD).*;
        reg(regAddr).* = value;
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_FIFOCMDADD).* = em.@"<>"(u16, ((hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCMD) & 0x0FFF) >> 2);
        Common.GlobalInterrupts.restore(key);
    }
};

//->> zigem publish #|e8c5a7e3dcedb5b12c1e5a42133f82a0f86f65b8b2b3d27dbb3cfd78a2e8d150|#

//->> EM__TARG publics
pub const prepare = EM__TARG.prepare;
pub const write = EM__TARG.write;

//->> zigem publish -- end of generated code
