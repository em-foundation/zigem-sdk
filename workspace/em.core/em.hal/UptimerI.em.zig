pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const Time = struct {
    secs: u32 = 0,
    subs: u32 = 0,
    ticks: u32 = 0,
};

pub const EM__SPEC = struct {
    calibrate: *const @TypeOf(EM__TARG.calibrate) = &EM__TARG.calibrate,
    read: *const @TypeOf(EM__TARG.read) = &EM__TARG.read,
    resetSync: *const @TypeOf(EM__TARG.resetSync) = &EM__TARG.resetSync,
    trim: *const @TypeOf(EM__TARG.trim) = &EM__TARG.trim,
};

pub const EM__TARG = struct {
    pub fn calibrate(secs256: u32, ticks: u32) u16 {
        // TODO
        _ = secs256;
        _ = ticks;
        return 0;
    }
    pub fn read() *const Time {
        // TODO
        return @ptrFromInt(4);
    }
    pub fn resetSync() void {
        // TODO
        return;
    }
    pub fn trim() u16 {
        // TODO
        return 0;
    }
};
