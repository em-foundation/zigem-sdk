pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{ .inherits = AppI });

pub const AppI = em.import.@"em.radio.core/AppI";
pub const AppRunner = em.import.@"em.radio.core/AppRunner";
pub const FirstAppS = em.import.@"em.radio.examples/Ex01_FirstApp_S";

const RT = FirstAppS.Schema.ResType;
const SCH = FirstAppS.Schema;

pub const EM__META = struct {
    //
    pub fn em__configureM() void {
        AppRunner.x_App.setM(em__U._U);
        AppRunner.x_Sch.setM(FirstAppS.Schema);
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
        em.print("buf = {x}\n", .{buf});
        buf += 1;
        SCH.store(1, bp);
        buf = 0;
        SCH.fetch(1, bp);
        em.print("buf = {x}\n", .{buf});
    }
};


//->> zigem publish #|f2cb2cf7df8a73841e310e387742d836e9db0b8a4e15fc313a14a2150ae857d1|#

//->> EM__META publics

//->> EM__TARG publics
pub const data_FETCH = EM__TARG.data_FETCH;
pub const data_STORE = EM__TARG.data_STORE;

//->> zigem publish -- end of generated code
