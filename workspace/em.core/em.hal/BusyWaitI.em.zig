pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__TARG = struct {
    wait: fn (usecs: u32) void,
};

//#region zigem

//->> zigem publish #|a1ae67a83e3ce70177e73ae5aa87d189d36f245152deadd19f7f39f9b339655a|#

pub fn wait(usecs: u32) void {
    // TODO
    _ = usecs;
    return em.std.mem.zeroes(void);
}

const em__Self = @This();

pub const EM__SPEC = struct {
    wait: *const @TypeOf(em__Self.wait) = &em__Self.wait,
};

//->> zigem publish -- end of generated code

//#endregion zigem
