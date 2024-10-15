// GENERATED FILE -- do not edit!!!

const em = @import("./zigem/em.zig");
const domain_desc = @import("zigem/domain.zig");
const uname = @import("zigem/check-unit.zig").uname;
const U = @field(em.import, uname);

test "main" {
    switch (domain_desc.DOMAIN) {
        .META => {
            em.std.testing.refAllDecls(U.EM__META);
        },
        .TARG => {
            em.std.testing.refAllDecls(U.EM__TARG);
        },
    }
}