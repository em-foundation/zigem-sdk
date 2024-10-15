const em = @import("./zigem/em.zig");
const domain_desc = @import("zigem/domain.zig");
const U = em.import.@".junk/Mod";

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
