pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const EM__TARG = struct {
    //
    const ROM_T = extern struct {
        enterStandby: ?*const fn ([*c]const u32) callconv(.C) void = @import("std").mem.zeroes(?*const fn ([*c]const u32) callconv(.C) void),
    };

    const ROM_TABLE: *const ROM_T = @ptrFromInt(0x0F00004C);

    pub fn enterStandby(addr: u32) void {
        ROM_TABLE.enterStandby.?(addr);
    }
};

//#region zigem

//->> zigem publish #|ad71067bbd793e62046a7b9387d053694e9f359133eea3a3b1b8ead65c58c2cb|#

//->> EM__TARG publics
pub const enterStandby = EM__TARG.enterStandby;

//->> zigem publish -- end of generated code

//#endregion zigem
