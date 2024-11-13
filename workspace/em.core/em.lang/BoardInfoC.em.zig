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

//#region zigem

//->> zigem publish #|cea13fe334282efca78b67796e2473f2b4b47d63023568f94f6b484832b60487|#

//->> zigem publish -- end of generated code

//#endregion zigem
