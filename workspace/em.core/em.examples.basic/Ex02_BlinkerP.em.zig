pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const Common = em.import.@"em.mcu/Common";

pub const EM__TARG = struct {
    //
    pub fn em__run() void {
        AppLed.on();
        for (0..10) |_| {
            Common.BusyWait.wait(500_000);
            AppLed.toggle();
        }
        AppLed.off();
    }
};

//#region zigem

//->> zigem publish #|e1de3e47e32719892c4bd16928102e33029fe87a1a4e8457893c59b2091dcb77|#

//->> EM__TARG publics

//->> zigem publish -- end of generated code

//#endregion zigem
