pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const Common = em.import.@"em.mcu/Common";

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    const RXF_UNWRAPPED_BASE_ADDR: u32 = 0x40093000;
    const TXF_UNWRAPPED_BASE_ADDR: u32 = 0x40093800;

    // uint32_t LRF_peekRxFifo(int32_t offset)
    // {
    //     int32_t index = HWREG_READ_LRF(LRFDPBE_BASE + LRFDPBE_O_RXFRP) + offset;
    //     int32_t fifosz = ((HWREG_READ_LRF(LRFDPBE_BASE + LRFDPBE_O_FCFG4) & LRFDPBE_FCFG4_RXSIZE_M) >> LRFDPBE_FCFG4_RXSIZE_S) << 2;
    //     if (index >= fifosz)
    //     {
    //         index -= fifosz;
    //     }
    //
    //     return HWREG_READ_LRF(LRFD_BUFRAM_BASE + (HWREG_READ_LRF(LRFDPBE_BASE + LRFDPBE_O_FCFG3) << 2) + index);
    // }

    pub fn peek(_: u32) u32 {
        var index = reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_RXFRP).*;
        const fifosz = em.as(u32, ((reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG4).* & hal.LRFDPBE_FCFG4_RXSIZE_M) >> hal.LRFDPBE_FCFG4_RXSIZE_S) << 2);
        if (index >= fifosz) index -= fifosz;
        const addr = em.as(c_int, reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG3).* << 2);
        return reg(hal.LRFD_BUFRAM_BASE + em.as(u32, addr)).*;
    }

    pub fn prepare() void {
        // RX fifo
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCMD).* = hal.LRFDPBE_FCMD_DATA_RXFIFO_RESET >> hal.LRFDPBE_FCMD_DATA_S;
        var rxcfg = reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG0).*;
        rxcfg &= ~(em.as(u32, (hal.LRFDPBE_FCFG0_RXADEAL_M | hal.LRFDPBE_FCFG0_RXACOM_M)));
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG0).* = rxcfg;
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_FIFOCMDADD).* = ((hal.LRFDPBE_BASE + hal.LRFDPBE_O_FSTAT) & 0x0FFF) >> 2;
        _ = em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_FIFOCMDADD).*;
        _ = em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_FIFOCMDADD).*;
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_RXFSRP).* = 32;
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_FIFOCMDADD).* = ((hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCMD) & 0x0FFF) >> 2;
        writeFifoPtr(reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_RXFRP).*, (hal.LRFDPBE_BASE + hal.LRFDPBE_O_RXFSRP));

        // TX fifo
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCMD).* = (hal.LRFDPBE_FCMD_DATA_TXFIFO_RESET >> hal.LRFDPBE_FCMD_DATA_S);
        var txcfg = reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG0).*;
        txcfg &= ~em.as(u32, hal.LRFDPBE_FCFG0_TXADEAL_M);
        txcfg |= hal.LRFDPBE_FCFG0_TXACOM_M;
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG0).* = txcfg;
    }

    pub fn write(data: []const u32) void {
        const fifoStart = ((reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG1).* & hal.LRFDPBE_FCFG1_TXSTRT_M) >> hal.LRFDPBE_FCFG1_TXSTRT_S) << 2;
        const writePointer = reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_TXFWP).* & ~em.as(u32, 0x0003);
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
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_FIFOCMDADD).* = em.as(u16, ((hal.LRFDPBE_BASE + hal.LRFDPBE_O_FSTAT) & 0x0FFF) >> 2);
        // delay
        _ = em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_FIFOCMDADD).*;
        _ = em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_FIFOCMDADD).*;
        reg(regAddr).* = value;
        em.reg16(hal.LRFD_BUFRAM_BASE + hal.PBE_COMMON_RAM_O_FIFOCMDADD).* = em.as(u16, ((hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCMD) & 0x0FFF) >> 2);
        Common.GlobalInterrupts.restore(key);
    }
};


//->> zigem publish #|0d6fab022be774cee9bbd155fc34dcb2e7cf3b9bd11eb89e5b7cb716fa37d498|#

//->> EM__TARG publics
pub const peek = EM__TARG.peek;
pub const prepare = EM__TARG.prepare;
pub const write = EM__TARG.write;

//->> zigem publish -- end of generated code
