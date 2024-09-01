pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const TXPOWER_REFERENCE_TEMPERATURE: i16 = 25;
pub const TXPOWER_TEMPERATURE_SCALING: i16 = 0x100;

pub const EM__HOST = struct {};

pub const EM__TARG = struct {
    //
    const hal = em.hal;
    const reg = em.reg;

    pub fn getTemperature() i16 {
        var temperature: i32 = @bitCast(reg(hal.PMUD_BASE + hal.PMUD_O_TEMP).*);
        temperature = (temperature & (hal.PMUD_TEMP_INT_M | hal.PMUD_TEMP_FRAC_M)) >> hal.PMUD_TEMP_FRAC_S;
        temperature = (temperature << (32 - (hal.PMUD_TEMP_INT_W + hal.PMUD_TEMP_FRAC_W))) >>
            (32 - (hal.PMUD_TEMP_INT_W + hal.PMUD_TEMP_FRAC_W));
        // scaleToReal
        const p1: i32 = 1094172;
        const p0: i32 = -7043721;
        temperature = (temperature * p1) + p0;
        const mask: i32 = (1 << 22);
        if (temperature > 0) {
            temperature = @divTrunc(temperature + mask, mask);
        } else {
            temperature = @divTrunc(temperature - mask, mask);
        }
        return @intCast(temperature);
    }
};
