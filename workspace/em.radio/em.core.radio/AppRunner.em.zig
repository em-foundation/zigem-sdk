pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    App: em.Proxy(AppI),
    Sch: em.Proxy(SchemaI),
};

pub const AppI = em.import.@"em.core.radio/AppI";
pub const SchemaI = em.import.@"em.core.radio/SchemaI";

pub const EM__META = struct {
    //
    pub const x_App = em__C.App;
    pub const x_Sch = em__C.Sch;

    pub fn em__constructM() void {
        em__C.Sch.getM().bindAppUpathM(em__C.App.em__upath);
    }
};

pub const EM__TARG = struct {
    //
    const App = em__C.App.unwrap();
    const Sch = em__C.Sch.unwrap();
};


//->> zigem publish #|faa8d830a7f909511348b3d721282988e36c81530a3b4fa91a77f7624ebff9df|#

//->> EM__META publics
pub const x_App = EM__META.x_App;
pub const x_Sch = EM__META.x_Sch;

//->> EM__TARG publics

//->> zigem publish -- end of generated code
