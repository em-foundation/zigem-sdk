const std = @import("std");
const Gist = @import("./gist/Gist05.zig");

const assert = std.debug.assert;

export fn main() void {
    if (@hasDecl(Gist, "em$startup")) {
        Gist.@"em$startup"();
    }
    comptime assert(@hasDecl(Gist, "em$run"));
    Gist.@"em$run"();
}
