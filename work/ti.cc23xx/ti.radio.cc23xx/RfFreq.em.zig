pub const em = @import("../../.gen/em.zig");
pub const em__U = em.Module(@This(), .{});

pub const EM__HOST = struct {};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    const P_FACTOR: u32 = 9;
    const P_SHIFT: u32 = 4;
    const Q_MAGN_SHIFT: u32 = 6;
    const FRAC_NUM_BITS: u32 = 28;
    const FRAC_EXTRA_BITS: u32 = (32 - FRAC_NUM_BITS);

    const fXtalInv = [_]u32{ 0x00001E52, 0x02CBD3F0 };

    fn countLeadingZeros(valueIn: u16) u32 {
        var value = valueIn;
        var numZeros: u32 = 0;
        if (value >= 0x0100) {
            value >>= 8;
        } else {
            numZeros += 8;
        }
        if (value >= 0x10) {
            value >>= 4;
        } else {
            numZeros += 4;
        }
        if (value >= 0x04) {
            value >>= 2;
        } else {
            numZeros += 2;
        }
        if (value >= 0x02) {} else {
            numZeros += 1;
        }
        return numZeros;
    }

    fn findFoff(frequencyOffset: i32, invSynthFreq: u32) u32 {
        if (frequencyOffset == 0) return 0;
        var absFrequencyOffset = if (frequencyOffset < 0) -frequencyOffset else frequencyOffset;
        absFrequencyOffset = (absFrequencyOffset + (1 << 5)) >> 6;
        absFrequencyOffset *= em.@"<>"(i32, invSynthFreq);
        absFrequencyOffset = (absFrequencyOffset + (1 << 19)) >> 20;
        const fOffRes = if (frequencyOffset < 0) -absFrequencyOffset else absFrequencyOffset;
        return (em.@"<>"(u32, fOffRes) & hal.LRFDRFE_MOD1_FOFF_M);
    }

    fn findCalM(frequency: u32, prediv: u32) u32 {
        var frefInv = (fXtalInv[1] >> 4) * prediv;
        frefInv += 1 << 15;
        frefInv >>= 16;
        var calM = frefInv * ((frequency + (1 << 14)) >> 15);
        calM += 1 << 15;
        calM >>= 16;
        return calM;
    }

    fn findLog2Bde1(demmisc3: u32) u32 {
        return if ((demmisc3 & hal.LRFDMDM_DEMMISC3_BDE1FILTMODE_M) != 0) 0 else (demmisc3 & hal.LRFDMDM_DEMMISC3_BDE1NUMSTAGES_M) >> hal.LRFDMDM_DEMMISC3_BDE1NUMSTAGES_S;
    }

    fn findPllMBase(frequency: u32) u32 {
        const frefInv = fXtalInv[1];
        var pllMBase = (frefInv >> 16) * (frequency >> 16);
        var tmpPllMBase = ((frefInv >> 16) * (frequency & 0xFFFF)) >> 1;
        tmpPllMBase += ((frefInv & 0xFFFF) * (frequency >> 16)) >> 1;
        tmpPllMBase += (1 << 14);
        tmpPllMBase >>= 15;
        pllMBase += tmpPllMBase;
        pllMBase += 1;
        pllMBase >>= 1;
        return pllMBase;
    }

    pub fn program(frequency: u32) void {
        const synthFrequency = frequency - 1_000_000; // tx freq offset
        const synthFrequencyCompensated = scaleFreqWithHFXTOffset(synthFrequency);
        const frequencyDiv2_16 = (synthFrequency + (1 << 15)) >> 16;
        reg(hal.LRFDRFE32_BASE + hal.LRFDRFE32_O_DIVIDEND).* = 1 << 31;
        reg(hal.LRFDRFE32_BASE + hal.LRFDRFE32_O_DIVISOR).* = frequencyDiv2_16;
        em.reg16(hal.LRFD_RFERAM_BASE + hal.RFE_COMMON_RAM_O_K5).* = em.@"<>"(u16, frequencyDiv2_16);
        var precalSetting = reg(hal.LRFDRFE32_BASE + hal.LRFDRFE32_O_PRE3_PRE2).*;
        const coarsePrecal = (precalSetting & hal.LRFDRFE32_PRE3_PRE2_CRSCALDIV_M) >> hal.LRFDRFE32_PRE3_PRE2_CRSCALDIV_S;
        const midPrecal = (precalSetting & (hal.LRFDRFE32_PRE3_PRE2_MIDCALDIVMSB_M | hal.LRFDRFE32_PRE3_PRE2_MIDCALDIVLSB_M)) >> hal.LRFDRFE_PRE2_MIDCALDIVLSB_S;
        const calMCoarse = findCalM(synthFrequency, coarsePrecal);
        const calMMid = if (coarsePrecal == midPrecal) calMCoarse else findCalM(synthFrequency, midPrecal);
        reg(hal.LRFDRFE32_BASE + hal.LRFDRFE32_O_CALMMID_CALMCRS).* = (calMCoarse << hal.LRFDRFE32_CALMMID_CALMCRS_CALMCRS_VAL_S) |
            (calMMid << hal.LRFDRFE32_CALMMID_CALMCRS_CALMMID_VAL_S);
        precalSetting = reg(hal.LRFDRFE32_BASE + hal.LRFDRFE32_O_PRE1_PRE0).*;
        const precal0 = (precalSetting & hal.LRFDRFE32_PRE1_PRE0_PLLDIV0_M) >> hal.LRFDRFE32_PRE1_PRE0_PLLDIV0_S;
        const precal1 = (precalSetting & hal.LRFDRFE32_PRE1_PRE0_PLLDIV1_M) >> hal.LRFDRFE32_PRE1_PRE0_PLLDIV1_S;
        const pllMBase = programPQ(findPllMBase(synthFrequency));
        const pllMBaseCompensated = if (synthFrequencyCompensated == synthFrequency) pllMBase else findPllMBase(synthFrequencyCompensated);
        reg(hal.LRFDRFE32_BASE + hal.LRFDRFE32_O_PLLM0).* = ((pllMBaseCompensated * precal0) << hal.LRFDRFE32_PLLM0_VAL_S);
        reg(hal.LRFDRFE32_BASE + hal.LRFDRFE32_O_PLLM1).* = ((pllMBaseCompensated * precal1) << hal.LRFDRFE32_PLLM1_VAL_S);
        while ((reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_DIVSTA).* & hal.LRFDRFE_DIVSTA_STAT_M) != 0) {}
        const invSynthFreq = reg(hal.LRFDRFE32_BASE + hal.LRFDRFE32_O_QUOTIENT).*;
        em.reg16(hal.LRFD_RFERAM_BASE + hal.RFE_COMMON_RAM_O_RXIF).* = em.@"<>"(u16, findFoff(0, invSynthFreq)); // rxFreqOff
        em.reg16(hal.LRFD_RFERAM_BASE + hal.RFE_COMMON_RAM_O_TXIF).* = em.@"<>"(u16, findFoff(1_000_000, invSynthFreq)); // txFreqOff
        programCMixN(1_000_000, invSynthFreq); // rxIntFreq
        // skip programShape
    }

    fn programCMixN(rxIntFrequency: i32, invSynthFreq: u32) void {
        var absRxIntFrequency = if (rxIntFrequency < 0) -rxIntFrequency else rxIntFrequency;
        absRxIntFrequency = (absRxIntFrequency + (1 << 5)) >> 6;
        var cMixN = em.@"<>"(u32, absRxIntFrequency) * invSynthFreq;
        cMixN = ((cMixN + (1 << 3)) >> 4) * 9;
        const rightShift = (37 - 15) - findLog2Bde1(reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_DEMMISC3).*);
        cMixN = (cMixN + (em.@"<>"(u32, 1) << (em.@"<>"(u5, rightShift) - 1))) >> em.@"<>"(u5, rightShift);
        const signedCMixN = if (rxIntFrequency > 0) -em.@"<>"(i32, cMixN) else em.@"<>"(i32, (cMixN));
        cMixN = (em.@"<>"(u32, signedCMixN) & hal.LRFDMDM_DEMMISC0_CMIXN_M);
        reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_DEMMISC0).* = cMixN;
        reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_SPARE3).* = cMixN;
    }

    fn programPQ(pllMBase: u32) u32 {
        var roundingError = false;
        var rateWord: u32 = (reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_BAUD).* << 5);
        rateWord |= ((reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_BAUDPRE).* & hal.LRFDMDM_BAUDPRE_EXTRATEWORD_M) >> hal.LRFDMDM_BAUDPRE_EXTRATEWORD_S);
        const pre: u32 = (reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_BAUDPRE).* & hal.LRFDMDM_BAUDPRE_PRESCALER_M);
        const demmisc3: u32 = reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_DEMMISC3).*;
        const log2Bde1 = findLog2Bde1(demmisc3);
        const bde2: u32 = (demmisc3 & hal.LRFDMDM_DEMMISC3_BDE2DECRATIO_M) >> hal.LRFDMDM_DEMMISC3_BDE2DECRATIO_S;
        const log2PdifDecim: u32 = (demmisc3 & hal.LRFDMDM_DEMMISC3_PDIFDECIM_M) >> hal.LRFDMDM_DEMMISC3_PDIFDECIM_S;
        var leftShiftP: u32 = log2Bde1 + log2PdifDecim + P_SHIFT;
        var demFracP: u32 = rateWord * bde2;
        if (demFracP > (em.@"<>"(u64, 1) << 32) / P_FACTOR) {
            if ((demFracP & 1) != 0) {
                roundingError = true;
            }
            demFracP >>= 1;
            leftShiftP -= 1;
        }
        demFracP *= P_FACTOR;
        var demFracQ: u32 = ((pllMBase + ((1 << Q_MAGN_SHIFT) - 1)) >> Q_MAGN_SHIFT) * pre;
        const num0Q: u32 = countLeadingZeros(em.@"<>"(u16, demFracQ >> 16));
        // TODO const pllMShift: i32 = em.@"<>"(i32, em.@"<>"(u32, Q_MAGN_SHIFT + FRAC_EXTRA_BITS - num0Q));
        const pllMShift: i32 = @bitCast(Q_MAGN_SHIFT + FRAC_EXTRA_BITS - num0Q);
        var pllMBaseRounded: u32 = undefined;
        if (pllMShift <= 0) {
            pllMBaseRounded = pllMBase;
            demFracQ = pllMBase * pre;
            const leftShiftQ = -pllMShift;
            leftShiftP += em.@"<>"(u32, leftShiftQ);
            demFracQ <<= em.@"<>"(u5, leftShiftQ);
        } else {
            const pshft5 = em.@"<>"(u5, pllMShift);
            pllMBaseRounded = (pllMBase + (@as(u32, 1) << (pshft5 - 1)) >> pshft5);
            demFracQ = pllMBaseRounded * pre;
            pllMBaseRounded <<= pshft5;
            leftShiftP -= em.@"<>"(u32, pllMShift);
        }
        var lshft5 = em.@"<>"(u5, leftShiftP);
        if (leftShiftP >= 0) {
            demFracP <<= lshft5;
        } else {
            lshft5 = em.@"<>"(u5, -leftShiftP);
            if ((demFracP & ((em.@"<>"(u32, 1) << lshft5) - 1)) != 0) {
                roundingError = true;
            }
            demFracP >>= lshft5;
        }

        //if (demFracP >= demFracQ)
        //{
        //    Log_printf(RclCore, Log_ERROR, "Error: resampler fraction greater than 1; demodulator will not work");
        //}
        //if (roundingError)
        //{
        //    Log_printf(RclCore, Log_WARNING, "Rounding error in fractional resampler");
        //}
        //if (pllMBaseRounded != pllMBase)
        //{
        //    Log_printf(RclCore, Log_INFO, "PLLM base rounded from %08X to %08X to fit in fractional resampler", pllMBase, pllMBaseRounded);
        //}

        reg(hal.LRFDMDM32_BASE + hal.LRFDMDM32_O_DEMFRAC1_DEMFRAC0).* = demFracP;
        reg(hal.LRFDMDM32_BASE + hal.LRFDMDM32_O_DEMFRAC3_DEMFRAC2).* = demFracQ;
        return pllMBaseRounded;
    }

    fn scaleFreqWithHFXTOffset(frequency: u32) u32 {
        const ratio = (reg(hal.CKMD_BASE + hal.CKMD_O_HFTRACKCTL).* & hal.CKMD_HFTRACKCTL_RATIO_M) >> hal.CKMD_HFTRACKCTL_RATIO_S;
        var freqOut = frequency;
        if (ratio != hal.CKMD_HFTRACKCTL_RATIO_REF48M) {
            const ah = frequency >> 16;
            const al = frequency & 0xFFFF;
            const bh = ratio >> 16;
            const bl = ratio & 0xFFFF;
            freqOut = ((bl * ah + bh * al + ((bl * al) >> 16)) >> 6) + ((bh * ah) << 10);
        }
        return frequency;
    }
};
