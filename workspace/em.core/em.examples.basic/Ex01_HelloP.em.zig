pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const EM__TARG = struct {
    //
    pub fn em__run() void {
        em.print("hello world\n", .{});
    }
};

//#region zigem

//->> zigem publish #|256984b9bc125ca7a1e49c8c18ac5fc88475efdcdd609556a604b4b47f986526|#

//->> EM__TARG publics

//->> zigem publish -- end of generated code

//#endregion zigem
