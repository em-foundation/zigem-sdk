pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const Common = em.Import.@"em.mcu/Common";

pub const FiberBody = em.CB(FiberBody_CB);
pub const FiberBody_CB = struct {
    arg: em.ptr_t,
};

pub const Fiber = struct {
    const Self = @This();
    link: ?*Fiber = null,
    body: em.Func(FiberBody),
    arg: em.ptr_t = null,
    pub fn post(self: *Self) void {
        em__unit.scope.Fiber_post(self);
    }
};

pub const a_heap = em__unit.array("a_heap", Fiber);

pub const EM__HOST = struct {
    //
    pub fn createH(body: em.Func(FiberBody)) em.Ref(Fiber) {
        const fiber = a_heap.alloc(.{ .body = body });
        return fiber;
    }
};

pub const EM__TARG = struct {
    //
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
            const body = fiber.body.unwrap();
            Common.GlobalInterrupts.enable();
            body(FiberBody_CB{ .arg = fiber.arg });
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

    pub fn Fiber_post(self: *Fiber) void {
        const key = Common.GlobalInterrupts.disable();
        if (self.link == null) ready_list.give(self);
        Common.GlobalInterrupts.restore(key);
    }
};
