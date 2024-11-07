pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__TARG = struct {
    startup: fn () void,
};


//->> zigem publish #|42d4d8fd897b21052682c9a4b7546c04fc22204db1e3555922a553e699b47bdd|#

pub fn startup () void {
    // TODO
    return em.std.mem.zeroes(void);
}

const em__Self = @This();

pub const EM__SPEC = struct {
    startup: *const @TypeOf(em__Self.startup) = &em__Self.startup,
};

//->> zigem publish -- end of generated code
