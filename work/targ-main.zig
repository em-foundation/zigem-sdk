const em = @import(".gen/em.zig");

export fn em__start() void {
    main();
}

fn main() void {
    @import("em.core/em.lang/targ-main.zig").exec(em.Unit.@"gist.cc23xx/Gist00_Min".em__unit) catch em.halt();
}
