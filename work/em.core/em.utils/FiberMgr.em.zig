pub const EM__SPEC = {};

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const FiberBodyFxn = em.Func(*const fn (arg: usize) void);

pub const Fiber = struct {
    const Self = @This();
    fxn: FiberBodyFxn,
    arg: usize = 0,
    pub fn post(self: *Self) void {
        Fiber_post(self);
    }
};

pub const a_heap = em__unit.Array("a_heap", Fiber);

pub const EM__HOST = {};

pub fn createH(fxn: FiberBodyFxn) em.Ref(Fiber) {
    const fiber = a_heap.alloc(.{ .fxn = fxn });
    return fiber;
}

pub const EM__TARG = {};

pub fn run() void {
    //
}

fn Fiber_post(self: *Fiber) void {
    _ = self;
}
