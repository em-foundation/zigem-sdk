pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const Common = em.Import.@"em.mcu/Common";

pub const _factory = em__unit.factory("Fiber", Fiber);
pub const Obj = em.Ptr(Fiber);

pub const FiberBody = struct {
    arg: usize,
};

pub const Fiber = struct {
    const Self = @This();
    link: ?Obj = null,
    body: em.Func(em.CB(FiberBody)),
    arg: usize = 0,
    pub fn post(self: *Self) void {
        em__unit.scope.Fiber_post(self);
    }
};

pub const EM__HOST = struct {
    //
    pub fn createH(body: em.Func(em.CB(FiberBody))) Obj {
        const fiber = _factory.createH(.{ .body = body });
        return fiber;
    }
};

pub const EM__TARG = struct {
    //
    var ready_list = struct {
        const Self = @This();
        const NIL: *Fiber = @ptrFromInt(4);
        head: *Fiber = NIL,
        tail: *Fiber = NIL,
        fn empty(self: *Self) bool {
            return self.head == NIL;
        }
        fn give(self: *Self, elem: *Fiber) void {
            if (self.empty()) {
                self.head = elem;
                self.tail = elem;
            } else {
                self.tail.link = elem;
            }
            elem.link = NIL;
        }
        fn take(self: *Self) *Fiber {
            const e = self.head;
            self.head = e.link.?;
            e.link = null;
            if (self.head == NIL) self.tail = NIL;
            return e;
        }
    }{};

    pub fn dispatch() void {
        while (!ready_list.empty()) {
            const fiber = ready_list.take();
            const body = fiber.body.unwrap();
            Common.GlobalInterrupts.enable();
            body(FiberBody{ .arg = fiber.arg });
            _ = Common.GlobalInterrupts.disable();
        }
    }

    pub fn run() void {
        Common.Idle.wakeup();
        Common.GlobalInterrupts.enable();
        while (true) {
            _ = Common.GlobalInterrupts.disable();
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
