const em = @import(".gen/em.zig");

pub fn main() !void {
    try @import("em.core/em.lang/meta-main.zig").exec(em.Unit.@"gist.cc23xx/Gist00_Min".em__unit);
}
