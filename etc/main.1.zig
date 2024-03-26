const std = @import("std");

const hal = struct {
    usingnamespace @import("hal/hw_memmap.zig");
    usingnamespace @import("hal/hw_gpio.zig");
    usingnamespace @import("hal/hw_ioc.zig");
};

fn REG(adr: u32) *volatile u32 {
    const reg: *volatile u32 = @ptrFromInt(adr);
    return reg;
}

fn done() void {
    var dummy: u32 = 0xCAFE;
    const vp: *volatile u32 = &dummy;
    while (vp.* != 0) {}
}

//fn Counter() type {
//    var T = struct {
//        const Self = @This();
//        _val: u8 = 0,
//        fn init() Self {
//            comptime return Self{};
//        }
//        fn inc(self: *Self) void {
//            comptime self._val += 1;
//        }
//        fn get(self: *Self) u8 {
//            return self._val;
//        }
//    };
//    return T;
//}

const Counter = struct {
    _val: u8 = 0,
    fn inc(self: *Counter) void {
        comptime self._val += 1;
    }
    fn get(self: *Counter) u8 {
        return self._val;
    }
};

fn mkCounter() Counter {
    comptime var c: Counter = .{};
    return c;
}

export fn main() void {
    comptime var ctr = mkCounter();
    comptime {
        ctr.inc();
        ctr.inc();
        std.debug.assert(ctr.get() == 2);
    }
    const pin = 14;
    const mask = (1 << pin);
    var k: u8 = ctr.get();
    while (k > 0) : (k -= 1) {
        REG(hal.GPIO_BASE + hal.GPIO_O_DOESET31_0).* = mask;
        REG(hal.IOC_BASE + hal.IOC_O_IOC0 + pin * 4).* &= ~hal.IOC_IOC0_INPEN;
        REG(hal.GPIO_BASE + hal.GPIO_O_DOUTSET31_0).* = mask;
    }

    //    REG(12345678).* = cnt.get();

    done();
}
