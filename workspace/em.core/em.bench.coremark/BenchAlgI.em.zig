pub const em = @import("../../zigem/em.zig");
pub const em__U = em.interface(@This(), .{});

pub const Utils = em.import.@"em.bench.coremark/Utils";

pub const EM__TARG = struct {
    dump: fn () void,
    kind: fn () Utils.Kind,
    print: fn () void,
    run: fn () void,
    setup: fn () void,
};


//->> zigem publish #|bf25a7f48bc28c8ea67cbefa2597e03d34bd452fdc348d417818d250ac49ea06|#

pub fn dump () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn kind () Utils.Kind {
    // TODO
    return em.std.mem.zeroes(Utils.Kind);
}

pub fn print () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn run () void {
    // TODO
    return em.std.mem.zeroes(void);
}

pub fn setup () void {
    // TODO
    return em.std.mem.zeroes(void);
}

const em__Self = @This();

pub const EM__SPEC = struct {
    dump: *const @TypeOf(em__Self.dump) = &em__Self.dump,
    kind: *const @TypeOf(em__Self.kind) = &em__Self.kind,
    print: *const @TypeOf(em__Self.print) = &em__Self.print,
    run: *const @TypeOf(em__Self.run) = &em__Self.run,
    setup: *const @TypeOf(em__Self.setup) = &em__Self.setup,
};

//->> zigem publish -- end of generated code
