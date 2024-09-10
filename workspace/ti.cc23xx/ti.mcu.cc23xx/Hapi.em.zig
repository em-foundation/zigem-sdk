pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

const ROM_T = extern struct {
    enterStandby: ?*const fn ([*c]const u32) callconv(.C) void = @import("std").mem.zeroes(?*const fn ([*c]const u32) callconv(.C) void),
};

const ROM_TABLE: *const ROM_T = @ptrFromInt(0x0F00004C);

pub const EM__META = struct {};

pub const EM__TARG = struct {
    //
    pub fn enterStandby(addr: u32) void {
        ROM_TABLE.enterStandby.?(addr);
    }
};
