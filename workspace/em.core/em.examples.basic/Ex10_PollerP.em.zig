pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});

pub const AppLed = em.import.@"em__distro/BoardC".AppLed;
pub const Common = em.import.@"em.mcu/Common";
pub const Poller = em.import.@"em.mcu/Poller";

pub const EM__TARG = struct {
    //
    pub fn em__run() void {
        Common.GlobalInterrupts.enable();
        for (0..5) |_| {
            Poller.upause(100_000); // 100ms
            AppLed.wink(5); // 5ms
        }
    }
};

//#region zigem

//->> zigem publish #|b60290887ce23c79598b43df0dd6ab7b31615d0bb08f5c5c3c8a4cf77136a3ab|#

//->> EM__TARG publics

//->> zigem publish -- end of generated code

//#endregion zigem
