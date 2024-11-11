pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const EM__TARG = struct {
    wait: fn (usecs: u32) void,
};


//->> zigem publish #|d28d3ca1774f4ed7b0e0737cf54d214d4372baee8fe22cffeff9c4bba74ca271|#

pub fn wait (usecs: u32) void {
    // TODO
    _ = usecs;
    return em.std.mem.zeroes(void);
}

const em__Self = @This();

pub const EM__SPEC = struct {
    wait: *const @TypeOf(em__Self.wait) = &em__Self.wait,
};

//->> zigem publish -- end of generated code
