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
        const addr = em.as(u32, hal.LRFD_BUFRAM_BASE + em.as(c_int, (reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG3).* << 2)));
        em.print("peek idx = {x}, sz = {}, addr = {x}\n", .{ index, fifosz, addr });
        return reg(addr).*;
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

    pub fn read(data: []u32, word_cnt: usize) void {
        var addr = em.as(u32, hal.LRFD_BUFRAM_BASE + em.as(c_int, (reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG3).* << 2)));
        for (0..word_cnt) |i| {
            // em.print("{}: {x}\n", .{ i, addr });
            data[i] = reg(addr).*;
            addr += 4;
        }

        // _ = EM__TARG.peek(0);
        // const fifoStart = ((reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG3).* & hal.LRFDPBE_FCFG3_RXSTRT_M) >> hal.LRFDPBE_FCFG3_RXSTRT_S) << 2;
        // const readPointer = reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_RXFWP).* & ~em.as(u32, 0x0003);
        // var fifoReadPtr: [*]volatile u32 = @ptrFromInt(RXF_UNWRAPPED_BASE_ADDR + fifoStart + readPointer);
        // em.print("read start = {x}, ptr = {}\n", .{ fifoStart, readPointer });
        // for (0..word_cnt) |i| {
        //     em.print("{}: {x}\n", .{ i, @intFromPtr(fifoReadPtr) });
        //     data[i] = fifoReadPtr[0];
        //     fifoReadPtr += 1;
        // }
        // var index = readPointer + (word_cnt * 4);
        // const fifosz = ((reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG4).* & hal.LRFDPBE_FCFG4_RXSIZE_M) >> hal.LRFDPBE_FCFG4_RXSIZE_S) << 2;
        // if (index >= fifosz) index -= fifosz;
        // writeFifoPtr(index, (hal.LRFDPBE_BASE + hal.LRFDPBE_O_RXFWP));
    }

    // void LRF_readRxFifoWords(uint32_t *data32, uint32_t wordLength)
    // {
    //     /* Due to RCL-367, the packet is read from memory, and the read pointer is updated afterwards */
    //     /* Pointer to unwrapped FIFO RAM representation */
    //     uint32_t fifoStart = ((HWREG_READ_LRF(LRFDPBE_BASE + LRFDPBE_O_FCFG3) & LRFDPBE_FCFG3_RXSTRT_M) >> LRFDPBE_FCFG3_RXSTRT_S) << 2;
    //     uint32_t readPointer = HWREG_READ_LRF(LRFDPBE_BASE + LRFDPBE_O_RXFRP) & ~0x0003;
    //     volatile uint32_t *fifoReadPtr = (volatile uint32_t *) (RXF_UNWRAPPED_BASE_ADDR + fifoStart + readPointer);
    //
    //     /* [RCL-515 WORKAROUND]: Protect the first memory write on BLE High PG1.x due to the hardware bugs */
    // #ifdef DeviceFamily_CC27XX
    //     ASM_4_NOPS();
    // #endif //DeviceFamily_CC27XX
    //     for (uint32_t i = 0; i < wordLength; i++) {
    //         *data32++ = *fifoReadPtr++;
    //     }
    //     /* Update read pointer */
    //     int32_t index = readPointer + (wordLength * 4);
    //     int32_t fifosz = ((HWREG_READ_LRF(LRFDPBE_BASE + LRFDPBE_O_FCFG4) & LRFDPBE_FCFG4_RXSIZE_M) >> LRFDPBE_FCFG4_RXSIZE_S) << 2;
    //     if (index >= fifosz)
    //     {
    //         index -= fifosz;
    //     }
    //     LRF_writeFifoPtr(index, (LRFDPBE_BASE + LRFDPBE_O_RXFRP));
    //     /* RP was moved, so RX FIFO is not deallocated */
    //     rxFifoDeallocated = false;
    // }

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


//->> zigem publish #|be9420d69d77183943269f94384f099415bb1efe5fe381fd48ad7d62be42af32|#

//->> EM__TARG publics
pub const peek = EM__TARG.peek;
pub const prepare = EM__TARG.prepare;
pub const read = EM__TARG.read;
pub const write = EM__TARG.write;

//->> zigem publish -- end of generated code
