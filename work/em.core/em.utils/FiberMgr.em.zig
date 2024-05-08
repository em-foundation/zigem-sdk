pub const EM__SPEC = {};

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const Common = em.Import.@"em.mcu/Common";

pub const FiberBodyFxn = fn (arg: usize) void;

pub const Fiber = struct {
    const Self = @This();
    link: ?*Fiber = null,
    fxn: em.Func(FiberBodyFxn),
    arg: usize = 0,
    pub fn post(self: *Self) void {
        Fiber_post(self);
    }
};

pub const a_heap = em__unit.array("a_heap", Fiber);

pub const EM__HOST = {};

pub fn createH(fxn: em.Func(FiberBodyFxn)) em.Ref(Fiber) {
    const fiber = a_heap.alloc(.{ .fxn = fxn });
    return fiber;
}

pub const EM__TARG = {};

var ready_list = struct {
    const Self = @This();
    const arr = a_heap.unwrap();
    head: ?*Fiber = null,
    tail: ?*Fiber = null,
    fn empty(self: *Self) bool {
        return self.head == null;
    }
    fn give(self: *Self, elem: *Fiber) void {
        if (self.empty()) self.head = elem;
        self.tail = elem;
    }
    fn take(self: *Self) *Fiber {
        const e = self.head.?;
        self.head = e.link;
        e.link = null;
        if (self.head == null) self.tail = null;
        return e;
    }
}{};

pub fn dispatch() void {
    while (!ready_list.empty()) {
        const fiber = ready_list.take();
        const fxn = fiber.fxn.unwrap();
        Common.GlobalInterrupts.enable();
        fxn(fiber.arg);
        _ = Common.GlobalInterrupts.enable();
    }
}

pub fn run() void {
    Common.Idle.wakeup();
    Common.GlobalInterrupts.enable();
    while (true) {
        _ = Common.GlobalInterrupts.enable();
        dispatch();
        Common.Idle.exec();
    }
}

fn Fiber_post(self: *Fiber) void {
    const key = Common.GlobalInterrupts.disable();
    if (self.link == null) ready_list.give(self);
    Common.GlobalInterrupts.restore(key);
}
