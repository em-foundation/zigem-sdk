pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const FirstAppS = em.import.@"em.radio.examples/Ex01_FirstApp_S";

const RT = FirstAppS.Schema.ResType;
const SCH = FirstAppS.Schema;

pub const EM__META = struct {
    //
    pub fn em__constructM() void {
        SCH.bindAppUpathM(em__U.upath);
    }
};

pub const EM__TARG = struct {
    //
    var data_val: RT(.data) = -40;

    pub fn data_FETCH(optr: *RT(.data)) void {
        optr.* = data_val;
    }

    pub fn data_STORE(iptr: *RT(.data)) void {
        data_val = iptr.*;
    }

    pub fn em__run() void {
        var buf: u32 = 0;
        const bp: *align(4) void = @ptrCast(&buf);
        SCH.fetch(1, bp);
        buf += 1;
        SCH.store(1, bp);
        buf = 0;
        SCH.fetch(1, bp);
        em.print("buf = {x}\n", .{buf});
    }
};


//->> zigem publish #|f2016b682557286d2d1a0811534b9ddbb81789764ff396a31360f8bbadb78d77|#

//->> EM__META publics

//->> EM__TARG publics
pub const data_FETCH = EM__TARG.data_FETCH;
pub const data_STORE = EM__TARG.data_STORE;

//->> zigem publish -- end of generated code
