pub const em = @import("../../zigem/em.zig");
pub const em__U = em.composite(@This(), .{});

const brd_name = em.property("em.lang.BoardKind", []const u8, "");

pub fn initFrom(BC: type) BC.BoardInfo {
    var res = BC.BoardInfo{};
    if (@hasDecl(BC, brd_name)) {
        _ = @call(.auto, @field(BC, brd_name), .{&res});
    }
    return res;
}

//->> zigem publish #|2a536a4e16838f1c8072086c2a82f5a11defe242b90130308540f87ff21233ee|#

//->> zigem publish -- end of generated code
