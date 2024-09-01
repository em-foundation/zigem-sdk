pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const RfTemp = em.import.@"ti.radio.cc23xx/RfTemp";

const TrimTempLdoRtrim = packed struct {
    rtrimMinOffset: u2,
    rtrimMaxOffset: u2,
    divLdoMinOffset: u2,
    divLdoMaxOffset: u2,
    tdcLdoMinOffset: u2,
    tdcLdoMaxOffset: u2,
    tThrl: u2,
    tThrh: u2,
};

const TrimTempRssiAgc = packed struct {
    rssiTcomp: i4,
    magnTcomp: i4,
    magnOffset: i4,
    rfu: i4,
    agcThrTcomp: i4,
    agcThrOffset: i4,
    lowGainOffset: i4,
    highGainOffset: i4,
};

const Trim0 = extern struct {
    pa0: u16,
    atstRefH: u16,
};

const Trim1 = extern struct {
    lna: u16,
    ifampRfLdo: u16,
    divLdo: packed struct {
        zero0: u8,
        voutTrim: u7,
        zero1: u1,
    },
    tdcLdo: packed struct {
        zero0: u8,
        voutTrim: u7,
        zero1: u1,
    },
};

const Trim2 = extern struct {
    dcoLdo0: u16,
    ifadcAldo: u16,
    ifadcDldo: u16,
    dco: packed struct {
        zero0: u3,
        tailresTrim: u4,
        zero1: u9,
    },
};

const TrimVariant = extern struct {
    ifadcQuant: u16,
    ifadc0: u16,
    ifadc1: u16,
    ifadclf: u16,
};

const Trim3 = extern struct {
    lrfdrfeExtTrim1: extern struct {
        tempLdoRtrim: TrimTempLdoRtrim,
        hfxtPdError: u8,
        res: u8,
    },
    lrfdrfeExtTrim0: TrimTempRssiAgc,
};

const Trim4 = extern struct {
    rssiOffset: u8,
    trimCompleteN: u8,
    demIQMC0: u16,
    res1: u16,
    ifamprfldo: [2]u8,
};

const AppTrims = extern struct {
    revision: u8,
    nToolsClientOffset: u8,
    reserved: [2]u8,
    trim0: Trim0,
    trim1: Trim1,
    trim2: Trim2,
    trimVariant: [2]TrimVariant,
    trim3: Trim3,
    trim4: Trim4,
};

const TRIMS: *const volatile AppTrims = @ptrFromInt(0x4E000330);

pub const EM__HOST = struct {};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    pub fn em__run() void {
        apply();
    }

    const TEMPERATURE_MIN = -40;
    const TEMPERATURE_MAX = 125;
    const TEMPERATURE_NOM = 25;
    const EXTTRIM0_TEMPERATURE_SCALE_EXP = 7;
    const EXTTRIM1_TEMPERATURE_SCALE_EXP = 4;
    const DIVLDO_LOW_TEMP_ADJ_FACTOR = 10;
    const DIVLDO_HIGH_TEMP_ADJ_FACTOR = 10;
    const TDCLDO_LOW_TEMP_ADJ_FACTOR = 10;
    const TDCLDO_HIGH_TEMP_ADJ_FACTOR = 10;
    const RTRIM_LOW_TEMP_ADJ_FACTOR = 1;
    const RTRIM_HIGH_TEMP_ADJ_FACTOR = 1;
    const DEFAULT_RTRIM_MAX = 12;
    const ONE_THIRD_MANTISSA = 21845;
    const ONE_THIRD_NEG_EXP = 16;
    const RFE_SPARE1_AGC_VALUE_BM = @as(u32, 0x000FF);
    const RFE_SPARE1_AGC_VALUE = 0;

    pub fn apply() void {
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_PA0).* |= TRIMS.trim0.pa0;
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_ATSTREFH).* |= TRIMS.trim0.atstRefH;
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_LNA).* |= TRIMS.trim1.lna;
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_IFAMPRFLDO).* |= TRIMS.trim1.ifampRfLdo;
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_DCOLDO0).* |= TRIMS.trim2.dcoLdo0;
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_IFADCALDO).* |= TRIMS.trim2.ifadcAldo;
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_IFADCDLDO).* |= TRIMS.trim2.ifadcDldo;
        reg(hal.LRFDMDM_BASE + hal.LRFDMDM_O_DEMIQMC0).* |= TRIMS.trim4.demIQMC0;
        em.reg16(hal.LRFD_RFERAM_BASE + hal.RFE_COMMON_RAM_O_IFAMPRFLDODEFAULT).* = em.reg16(hal.LRFDRFE_BASE + hal.LRFDRFE_O_IFAMPRFLDO).* & @as(u16, hal.LRFDRFE_IFAMPRFLDO_TRIM_M);
        // common: bwIndex = 0, bwIndexDither = 1
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_IFADCQUANT).* |= TRIMS.trimVariant[0].ifadcQuant;
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_IFADC0).* |= TRIMS.trimVariant[0].ifadc0;
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_IFADC1).* |= TRIMS.trimVariant[0].ifadc1;
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_IFADCLF).* |= TRIMS.trimVariant[0].ifadclf;
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_IFAMPRFLDO).* |= TRIMS.trim4.ifamprfldo[0];
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_IFADC0).* &= ~(hal.LRFDRFE_IFADC0_DITHEREN_M | hal.LRFDRFE_IFADC0_DITHERTRIM_M) |
            (TRIMS.trimVariant[1].ifadc0 & (hal.LRFDRFE_IFADC0_DITHEREN_M | hal.LRFDRFE_IFADC0_DITHERTRIM_M));

        // temperature
        em.reg16(hal.LRFD_RFERAM_BASE + hal.RFE_COMMON_RAM_O_DIVLDOF).* &= ~(@as(u16, hal.RFE_COMMON_RAM_DIVLDOF_VOUTTRIM_M));
        em.reg16(hal.LRFD_RFERAM_BASE + hal.RFE_COMMON_RAM_O_DIVLDOI).* &= ~(@as(u16, hal.RFE_COMMON_RAM_DIVLDOI_VOUTTRIM_M));
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_TDCLDO).* &= ~hal.LRFDRFE_TDCLDO_VOUTTRIM_M;
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_DCO).* &= ~hal.LRFDRFE_DCO_TAILRESTRIM_M;
        temperatureCompensateTrim();
    }

    fn findExtTrim0TrimAdjustment(temperature: i32, tempCompFactor: i32, offset: i32) i32 {
        return (((temperature - TEMPERATURE_NOM) * tempCompFactor) >> EXTTRIM0_TEMPERATURE_SCALE_EXP) + offset;
    }

    fn findExtTrim1TrimAdjustment(temperatureDiff: u32, tempThreshFactor: u32, maxAdjustment: u32) u32 {
        var adjustment: u32 = 0;
        switch (tempThreshFactor) {
            1 => {
                adjustment = ((temperatureDiff * maxAdjustment) + (1 << (EXTTRIM1_TEMPERATURE_SCALE_EXP - 1))) >> EXTTRIM1_TEMPERATURE_SCALE_EXP;
            },
            2 => {
                adjustment = ((temperatureDiff * maxAdjustment) + (1 << EXTTRIM1_TEMPERATURE_SCALE_EXP)) >> (EXTTRIM1_TEMPERATURE_SCALE_EXP + 1);
            },
            3 => {
                adjustment = ((temperatureDiff * maxAdjustment * ONE_THIRD_MANTISSA) + (1 << (EXTTRIM1_TEMPERATURE_SCALE_EXP + ONE_THIRD_NEG_EXP - 1))) >> (EXTTRIM1_TEMPERATURE_SCALE_EXP + ONE_THIRD_NEG_EXP);
            },
            else => {},
        }
        return adjustment;
    }

    fn temperatureCompensateTrim() void {
        var divLdoTempOffset: u32 = 0;
        var tdcLdoTempOffset: u32 = 0;
        var rtrimTempOffset: u32 = 0;
        var rssiTempOffset: i32 = 0;
        var agcValOffset: i32 = 0;

        const temperature = RfTemp.getTemperature();
        const tempLdoRtrim = TRIMS.trim3.lrfdrfeExtTrim1.tempLdoRtrim;
        const tempThreshLow = TEMPERATURE_MIN + @as(i16, @bitCast(@as(u16, tempLdoRtrim.tThrl) * (1 << EXTTRIM1_TEMPERATURE_SCALE_EXP)));
        const tempThreshHigh = TEMPERATURE_MAX - @as(i16, @bitCast(@as(u16, tempLdoRtrim.tThrh) * (1 << EXTTRIM1_TEMPERATURE_SCALE_EXP)));
        if (temperature < tempThreshLow) {
            const temperatureDiff: u32 = @as(u16, @bitCast(tempThreshLow - temperature));
            divLdoTempOffset = findExtTrim1TrimAdjustment(temperatureDiff, tempLdoRtrim.tThrl, DIVLDO_LOW_TEMP_ADJ_FACTOR * @as(u32, tempLdoRtrim.divLdoMinOffset));
            tdcLdoTempOffset = findExtTrim1TrimAdjustment(temperatureDiff, tempLdoRtrim.tThrl, TDCLDO_LOW_TEMP_ADJ_FACTOR * @as(u32, tempLdoRtrim.tdcLdoMinOffset));
            rtrimTempOffset = findExtTrim1TrimAdjustment(temperatureDiff, tempLdoRtrim.tThrl, RTRIM_LOW_TEMP_ADJ_FACTOR * @as(u32, tempLdoRtrim.rtrimMinOffset));
        } else if (temperature > tempThreshHigh) {
            const temperatureDiff: u32 = @as(u16, @bitCast(temperature - tempThreshHigh));
            divLdoTempOffset = findExtTrim1TrimAdjustment(temperatureDiff, tempLdoRtrim.tThrh, DIVLDO_HIGH_TEMP_ADJ_FACTOR * @as(u32, tempLdoRtrim.divLdoMaxOffset));
            tdcLdoTempOffset = findExtTrim1TrimAdjustment(temperatureDiff, tempLdoRtrim.tThrh, TDCLDO_HIGH_TEMP_ADJ_FACTOR * @as(u32, tempLdoRtrim.tdcLdoMaxOffset));
            rtrimTempOffset = findExtTrim1TrimAdjustment(temperatureDiff, tempLdoRtrim.tThrh, RTRIM_HIGH_TEMP_ADJ_FACTOR * @as(u32, tempLdoRtrim.rtrimMaxOffset));
        }
        rssiTempOffset = findExtTrim0TrimAdjustment(temperature, TRIMS.trim3.lrfdrfeExtTrim0.rssiTcomp, 0);
        // std AGC
        agcValOffset = findExtTrim0TrimAdjustment(temperature, TRIMS.trim3.lrfdrfeExtTrim0.magnTcomp, TRIMS.trim3.lrfdrfeExtTrim0.magnOffset);
        var divLdoVoutTrim: u32 = TRIMS.trim1.divLdo.voutTrim;
        divLdoVoutTrim ^= 0x40;
        divLdoVoutTrim += divLdoTempOffset;
        const DIV_ONES = (hal.LRFDRFE_DIVLDO_VOUTTRIM_ONES >> hal.LRFDRFE_DIVLDO_VOUTTRIM_S);
        if (divLdoVoutTrim > DIV_ONES) divLdoVoutTrim = DIV_ONES;
        em.reg16(hal.LRFD_RFERAM_BASE + hal.RFE_COMMON_RAM_O_DIVLDOF).* |= @intCast(((divLdoVoutTrim ^ 0x40) << hal.RFE_COMMON_RAM_DIVLDOF_VOUTTRIM_S));
        divLdoVoutTrim += em.reg16(hal.LRFD_RFERAM_BASE + hal.RFE_COMMON_RAM_O_DIVLDOIOFF).*;
        if (divLdoVoutTrim > DIV_ONES) divLdoVoutTrim = DIV_ONES;
        em.reg16(hal.LRFD_RFERAM_BASE + hal.RFE_COMMON_RAM_O_DIVLDOI).* |= @intCast(((divLdoVoutTrim ^ 0x40) << hal.RFE_COMMON_RAM_DIVLDOI_VOUTTRIM_S));
        var tdcLdoVoutTrim: u32 = TRIMS.trim1.tdcLdo.voutTrim;
        if (tdcLdoTempOffset > 0) {
            tdcLdoVoutTrim ^= 0x40;
            tdcLdoVoutTrim += tdcLdoTempOffset;
            const TDC_ONES = (hal.LRFDRFE_TDCLDO_VOUTTRIM_ONES >> hal.LRFDRFE_DIVLDO_VOUTTRIM_S);
            if (tdcLdoVoutTrim > TDC_ONES) tdcLdoVoutTrim = TDC_ONES;
            tdcLdoVoutTrim ^= 0x40;
        }
        em.reg16(hal.LRFDRFE_BASE + hal.LRFDRFE_O_TDCLDO).* |= @intCast((tdcLdoVoutTrim << hal.LRFDRFE_TDCLDO_VOUTTRIM_S));
        var rtrim: u32 = TRIMS.trim2.dco.tailresTrim;
        if (rtrim < DEFAULT_RTRIM_MAX) {
            rtrim += rtrimTempOffset;
            rtrim += em.reg16(hal.LRFD_RFERAM_BASE + hal.RFE_COMMON_RAM_O_RTRIMOFF).*;
            if (rtrim > DEFAULT_RTRIM_MAX) rtrim = DEFAULT_RTRIM_MAX;
        }
        const minRtrim: u32 = em.reg16(hal.LRFD_RFERAM_BASE + hal.RFE_COMMON_RAM_O_RTRIMMIN).*;
        if (rtrim < minRtrim) rtrim = minRtrim;
        em.reg16(hal.LRFDRFE_BASE + hal.LRFDRFE_O_DCO).* |= @intCast(rtrim << hal.LRFDRFE_DCO_TAILRESTRIM_S);
        var rssiOffset: i32 = em.@"<>"(i32, TRIMS.trim4.rssiOffset);
        if (TRIMS.revision == 4 and rssiOffset <= -4) rssiOffset += 5;
        rssiOffset += rssiTempOffset;
        rssiOffset += em.reg16(hal.LRFD_RFERAM_BASE + hal.RFE_COMMON_RAM_O_PHYRSSIOFFSET).*;
        em.reg16(hal.LRFDRFE_BASE + hal.LRFDRFE_O_RSSIOFFSET).* = @intCast(rssiOffset);
        const spare0Val: u32 = em.reg16(hal.LRFD_RFERAM_BASE + hal.RFE_COMMON_RAM_O_SPARE0SHADOW).*;
        em.reg16(hal.LRFDRFE_BASE + hal.LRFDRFE_O_SPARE0).* = @intCast(spare0Val);
        var spare1Val: u32 = em.reg16(hal.LRFD_RFERAM_BASE + hal.RFE_COMMON_RAM_O_SPARE1SHADOW).*;
        if (agcValOffset != 0) {
            var agcVal: i32 = @bitCast((spare1Val & RFE_SPARE1_AGC_VALUE_BM) >> RFE_SPARE1_AGC_VALUE);
            agcVal += agcValOffset;
            if (agcVal < 0) agcVal = 0;
            const sval = (RFE_SPARE1_AGC_VALUE_BM >> RFE_SPARE1_AGC_VALUE);
            if (agcVal > sval) agcVal = sval;
            spare1Val = (spare1Val & ~RFE_SPARE1_AGC_VALUE_BM) | @as(u32, @bitCast(agcVal << RFE_SPARE1_AGC_VALUE));
        }
        em.reg16(hal.LRFDRFE_BASE + hal.LRFDRFE_O_SPARE1).* = @intCast(spare1Val);
    }
};
