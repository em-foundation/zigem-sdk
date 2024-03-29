const std = @import("std");
const em = @import("./em.zig");
//const Gist = @import("./gist/Gist05.zig");

const Mod = @import("./scratch/ModA.zig");

const assert = std.debug.assert;

export fn main() void {
    comptime {
        @compileLog(Mod.em__spec.upath);
        for (Mod.em__spec.uses) |imp| {
            @compileLog(imp);
        }
    }
    //    if (@hasDecl(Gist, "em$startup")) {
    //        Gist.@"em$startup"();
    //    }
    //    comptime assert(@hasDecl(Gist, "em$run"));
    //    Gist.@"em$run"();
}
