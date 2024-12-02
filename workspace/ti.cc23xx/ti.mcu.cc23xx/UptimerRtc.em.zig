pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{
    .inherits = UptimerI,
});

pub const Rtc = em.import.@"ti.mcu.cc23xx/Rtc";
pub const TimeTypes = em.import.@"em.utils/TimeTypes";
pub const UptimerI = em.import.@"em.hal/UptimerI";

pub const EM__TARG = struct {
    //
    pub fn read() TimeTypes.RawTime {
        return Rtc.getRawTime();
    }
};

//#region zigem

//->> zigem publish #|793380061099d71157a4cd1a1c0e26225ae76d5574387f9802b101af2b14d79a|#

//->> EM__TARG publics
pub const read = EM__TARG.read;

//->> zigem publish -- end of generated code

//#endregion zigem
