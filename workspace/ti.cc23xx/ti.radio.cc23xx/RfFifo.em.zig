pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const Common = em.import.@"em.mcu/Common";

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    const RXF_UNWRAPPED_BASE_ADDR: u32 = 0x40093000;
    const TXF_UNWRAPPED_BASE_ADDR: u32 = 0x40093800;

    pub fn peek(_: u32) u32 {
        var index = reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_RXFRP).*;
        const fifosz = em.as(u32, ((reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG4).* & hal.LRFDPBE_FCFG4_RXSIZE_M) >> hal.LRFDPBE_FCFG4_RXSIZE_S) << 2);
        if (index >= fifosz) index -= fifosz;
        const addr = em.as(u32, hal.LRFD_BUFRAM_BASE + em.as(c_int, (reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG3).* << 2)));
        em.print("peek idx = {x}, sz = {}, addr = {x}\n", .{ index, fifosz, addr });
        return reg(addr).*;
    }

    pub fn prepareRX() void {
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCMD).* = hal.LRFDPBE_FCMD_DATA_RXFIFO_RESET >> hal.LRFDPBE_FCMD_DATA_S;
        var rxcfg = reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG0).*;
        rxcfg &= ~(em.as(u32, (hal.LRFDPBE_FCFG0_RXADEAL_M | hal.LRFDPBE_FCFG0_RXACOM_M)));
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG0).* = rxcfg;
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_RXFSRP).* = 256;
    }

    pub fn prepareTX() void {
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCMD).* = (hal.LRFDPBE_FCMD_DATA_TXFIFO_RESET >> hal.LRFDPBE_FCMD_DATA_S);
        var txcfg = reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG0).*;
        txcfg &= ~em.as(u32, hal.LRFDPBE_FCFG0_TXADEAL_M);
        txcfg |= hal.LRFDPBE_FCFG0_TXACOM_M;
        reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG0).* = txcfg;
    }

    pub fn read(data: []u32, word_cnt: usize) void {
        var addr = em.as(u32, hal.LRFD_BUFRAM_BASE + em.as(c_int, (reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG3).* << 2)));
        for (0..word_cnt) |i| {
            data[i] = reg(addr).*;
            addr += 4;
        }
    }

    pub fn writePkt(pkt: []const u8) void {
        EM__TARG.prepareTX();
        const sz = em.as(u8, pkt.len);
        var word = em.as(u32, 0x02030000) | (sz + 4);
        var addr = em.as(u32, hal.LRFD_BUFRAM_BASE + em.as(c_int, (reg(hal.LRFDPBE_BASE + hal.LRFDPBE_O_FCFG1).* << 2)));
        reg(addr).* = word;
        addr += 4;
        word = em.as(u32, 0x00000001);
        var mask: u32 = 0x00ff0000;
        var shift: u5 = 16;
        for (pkt) |b| {
            if (mask == 0) {
                mask = 0x000000ff;
                shift = 0;
                reg(addr).* = word;
                addr += 4;
                word = 0x00000000;
            }
            word = (word & ~mask) | em.as(u32, b) << shift;
            mask <<= 8;
            shift += 8;
        }
        reg(addr).* = word;
        writeFifoPtr(addr + 4, (hal.LRFDPBE_BASE + hal.LRFDPBE_O_TXFWP));
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


//->> zigem publish #|f8671f45d5c0d8e56b82253f57c752cb423ac047fefb344d4e2119b556651b5f|#

//->> EM__TARG publics
pub const peek = EM__TARG.peek;
pub const prepareRX = EM__TARG.prepareRX;
pub const prepareTX = EM__TARG.prepareTX;
pub const read = EM__TARG.read;
pub const writePkt = EM__TARG.writePkt;

//->> zigem publish -- end of generated code
