pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const RfTemp = em.import.@"ti.radio.cc23xx/RfTemp";

const TableEntry = packed struct {
    power: packed struct {
        fraction: u1,
        dBm: i7,
    },
    tempCoeff: u8,
    value: packed union {
        bits: packed struct {
            reserved: u5,
            ib: u6,
            gain: u3,
            mode: u1,
            noIfampRfLdoBypass: u1,
        },
        raw: u16,
    },
};

const TABLE = [_]TableEntry{
    .{ .power = .{ .fraction = 0, .dBm = -20 }, .tempCoeff = 0, .value = .{ .bits = .{ .reserved = 0, .ib = 18, .gain = 0, .mode = 0, .noIfampRfLdoBypass = 0 } } },
    .{ .power = .{ .fraction = 0, .dBm = -16 }, .tempCoeff = 0, .value = .{ .bits = .{ .reserved = 0, .ib = 20, .gain = 1, .mode = 0, .noIfampRfLdoBypass = 0 } } },
    .{ .power = .{ .fraction = 0, .dBm = -12 }, .tempCoeff = 5, .value = .{ .bits = .{ .reserved = 0, .ib = 17, .gain = 3, .mode = 0, .noIfampRfLdoBypass = 0 } } },
    .{ .power = .{ .fraction = 0, .dBm = -8 }, .tempCoeff = 12, .value = .{ .bits = .{ .reserved = 0, .ib = 17, .gain = 4, .mode = 0, .noIfampRfLdoBypass = 0 } } },
    .{ .power = .{ .fraction = 0, .dBm = -4 }, .tempCoeff = 25, .value = .{ .bits = .{ .reserved = 0, .ib = 17, .gain = 5, .mode = 0, .noIfampRfLdoBypass = 0 } } },
    .{ .power = .{ .fraction = 0, .dBm = 0 }, .tempCoeff = 40, .value = .{ .bits = .{ .reserved = 0, .ib = 19, .gain = 6, .mode = 0, .noIfampRfLdoBypass = 0 } } },
    .{ .power = .{ .fraction = 0, .dBm = 1 }, .tempCoeff = 65, .value = .{ .bits = .{ .reserved = 0, .ib = 30, .gain = 6, .mode = 0, .noIfampRfLdoBypass = 0 } } },
    .{ .power = .{ .fraction = 0, .dBm = 2 }, .tempCoeff = 41, .value = .{ .bits = .{ .reserved = 0, .ib = 39, .gain = 4, .mode = 1, .noIfampRfLdoBypass = 0 } } },
    .{ .power = .{ .fraction = 0, .dBm = 3 }, .tempCoeff = 43, .value = .{ .bits = .{ .reserved = 0, .ib = 31, .gain = 5, .mode = 1, .noIfampRfLdoBypass = 0 } } },
    .{ .power = .{ .fraction = 0, .dBm = 4 }, .tempCoeff = 50, .value = .{ .bits = .{ .reserved = 0, .ib = 37, .gain = 5, .mode = 1, .noIfampRfLdoBypass = 0 } } },
    .{ .power = .{ .fraction = 0, .dBm = 5 }, .tempCoeff = 55, .value = .{ .bits = .{ .reserved = 0, .ib = 27, .gain = 6, .mode = 1, .noIfampRfLdoBypass = 0 } } },
    .{ .power = .{ .fraction = 0, .dBm = 6 }, .tempCoeff = 75, .value = .{ .bits = .{ .reserved = 0, .ib = 38, .gain = 6, .mode = 1, .noIfampRfLdoBypass = 0 } } },
    .{ .power = .{ .fraction = 0, .dBm = 7 }, .tempCoeff = 80, .value = .{ .bits = .{ .reserved = 0, .ib = 25, .gain = 7, .mode = 1, .noIfampRfLdoBypass = 0 } } },
    .{ .power = .{ .fraction = 0, .dBm = 8 }, .tempCoeff = 180, .value = .{ .bits = .{ .reserved = 0, .ib = 63, .gain = 7, .mode = 1, .noIfampRfLdoBypass = 0 } } },
};

pub const EM__HOST = struct {};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    fn findEntry(level: i8) TableEntry {
        for (TABLE[0..]) |entry| {
            if (entry.power.dBm >= level) return entry;
        }
        return TABLE[TABLE.len - 1];
    }

    pub fn program(level: i8) void {
        const entry = findEntry(level);
        const tempCoeff = entry.tempCoeff;
        var value = entry.value;
        if (tempCoeff != 0) {
            var ib: i32 = value.bits.ib;
            const temperature = RfTemp.getTemperature();
            // em.print("coeff = {d}, ib = {d}, temp = {d}\n", .{ tempCoeff, ib, temperature });
            const IB_MIN: i32 = 1;
            const IB_MAX = em.@"<>"(i32, hal.LRFDRFE_PA0_IB_MAX >> hal.LRFDRFE_PA0_IB_S);
            ib += @divTrunc((temperature - RfTemp.TXPOWER_REFERENCE_TEMPERATURE) * em.@"<>"(i16, tempCoeff), RfTemp.TXPOWER_TEMPERATURE_SCALING);
            if (ib < IB_MIN) ib = IB_MIN else if (ib > IB_MAX) ib = IB_MAX;
            value.bits.ib = em.@"<>"(u6, ib);
        }
        reg(hal.LRFDRFE_BASE + hal.LRFDRFE_O_SPARE5).* = value.raw;
    }
};
