pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

const TableEntry = struct {
    power: struct {
        fraction: u1,
        dbM: i7,
    },
    tempCoeff: u8,
    value: struct {
        reserved: u5,
        ib: u6,
        gain: u3,
        mode: u1,
        noIfampRFLodBypass: u1,
    },
};

const TABLE = [_]TableEntry{
    .{ .power = .{ .fraction = 0, .dBm = -20 }, .tempCoeff = 0, .value = .{ .reserved = 0, .ib = 18, .gain = 0, .mode = 0, .noIfampRfLdoBypass = 0 } },
    .{ .power = .{ .fraction = 0, .dBm = -16 }, .tempCoeff = 0, .value = .{ .reserved = 0, .ib = 20, .gain = 1, .mode = 0, .noIfampRfLdoBypass = 0 } },
    .{ .power = .{ .fraction = 0, .dBm = -12 }, .tempCoeff = 5, .value = .{ .reserved = 0, .ib = 17, .gain = 3, .mode = 0, .noIfampRfLdoBypass = 0 } },
    .{ .power = .{ .fraction = 0, .dBm = -8 }, .tempCoeff = 12, .value = .{ .reserved = 0, .ib = 17, .gain = 4, .mode = 0, .noIfampRfLdoBypass = 0 } },
    .{ .power = .{ .fraction = 0, .dBm = -4 }, .tempCoeff = 25, .value = .{ .reserved = 0, .ib = 17, .gain = 5, .mode = 0, .noIfampRfLdoBypass = 0 } },
    .{ .power = .{ .fraction = 0, .dBm = 0 }, .tempCoeff = 40, .value = .{ .reserved = 0, .ib = 19, .gain = 6, .mode = 0, .noIfampRfLdoBypass = 0 } },
    .{ .power = .{ .fraction = 0, .dBm = 1 }, .tempCoeff = 65, .value = .{ .reserved = 0, .ib = 30, .gain = 6, .mode = 0, .noIfampRfLdoBypass = 0 } },
    .{ .power = .{ .fraction = 0, .dBm = 2 }, .tempCoeff = 41, .value = .{ .reserved = 0, .ib = 39, .gain = 4, .mode = 1, .noIfampRfLdoBypass = 0 } },
    .{ .power = .{ .fraction = 0, .dBm = 3 }, .tempCoeff = 43, .value = .{ .reserved = 0, .ib = 31, .gain = 5, .mode = 1, .noIfampRfLdoBypass = 0 } },
    .{ .power = .{ .fraction = 0, .dBm = 4 }, .tempCoeff = 50, .value = .{ .reserved = 0, .ib = 37, .gain = 5, .mode = 1, .noIfampRfLdoBypass = 0 } },
    .{ .power = .{ .fraction = 0, .dBm = 5 }, .tempCoeff = 55, .value = .{ .reserved = 0, .ib = 27, .gain = 6, .mode = 1, .noIfampRfLdoBypass = 0 } },
    .{ .power = .{ .fraction = 0, .dBm = 6 }, .tempCoeff = 75, .value = .{ .reserved = 0, .ib = 38, .gain = 6, .mode = 1, .noIfampRfLdoBypass = 0 } },
    .{ .power = .{ .fraction = 0, .dBm = 7 }, .tempCoeff = 80, .value = .{ .reserved = 0, .ib = 25, .gain = 7, .mode = 1, .noIfampRfLdoBypass = 0 } },
    .{ .power = .{ .fraction = 0, .dBm = 8 }, .tempCoeff = 180, .value = .{ .reserved = 0, .ib = 63, .gain = 7, .mode = 1, .noIfampRfLdoBypass = 0 } },
};

pub const EM__HOST = struct {};

pub const EM__TARG = struct {
    //
    fn findEntry(level: i8) TableEntry {
        for (TABLE[0..]) |entry| {
            if (entry.power.dbM >= level) return entry;
        }
        return TABLE[TABLE.len - 1];
    }

    pub fn program(level: i8) void {
        const entry = findEntry(level);
        const tempCoeff = entry.tempCoeff;
        if (tempCoeff != 0) {
            //const ib: i32 = entry.value.ib;
        }
        //        int32_t ib = txPowerEntry.value.ib;
        //        int32_t temperature = hal_get_temperature();
        //        /* Linear adjustment of IB field as a function of temperature, scaled
        //         * by the coefficient for the given setting */
        //        ib += ((temperature - LRF_TXPOWER_REFERENCE_TEMPERATURE) * (int32_t) tempCoeff)
        //            / LRF_TXPOWER_TEMPERATURE_SCALING;
        //        /* Saturate IB */
        //        if (ib < (int32_t) RFE_PA0_IB_MIN_USED)
        //        {
        //            ib = RFE_PA0_IB_MIN_USED;
        //        }
        //#ifdef DeviceFamily_CC27XX
        //        /* TODO: See RCL-444. Use LRFDRFE_PA1_IB_MAX for CC27XX. */
        //        if (ib > (int32_t) (LRFDRFE_PA1_IB_MAX >> LRFDRFE_PA1_IB_S))
        //        {
        //            ib = LRFDRFE_PA1_IB_MAX >> LRFDRFE_PA1_IB_S;
        //        }
        //#else
        //        if (ib > (int32_t) (LRFDRFE_PA0_IB_MAX >> LRFDRFE_PA0_IB_S))
        //        {
        //            ib = LRFDRFE_PA0_IB_MAX >> LRFDRFE_PA0_IB_S;
        //        }
        //#endif
        //        txPowerEntry.value.ib = ib;
        //    }
        //    /* Program into RFE shadow register for PA power */
        //    HWREG_WRITE_LRF(LRFDRFE_BASE + LRFDRFE_O_SPARE5) = txPowerEntry.value.rawValue;
        //
    }
};
