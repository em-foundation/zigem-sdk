const scalar = 6;

pub fn wait(usecs: u32) void {
    if (usecs == 0) return;
    var dummy: u32 = undefined;
    var p: *volatile u32 = &dummy;
    var i: u32 = 0;
    while (i < usecs * scalar) : (i += 1) {
        p.* = 0;
    }
}
