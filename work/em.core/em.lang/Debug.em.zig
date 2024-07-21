pub const em = @import("../../.gen/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    DbgA: em.Proxy(GpioI),
    DbgB: em.Proxy(GpioI),
    DbgC: em.Proxy(GpioI),
    DbgD: em.Proxy(GpioI),
};

const Common = em.import.@"em.mcu/Common";
const GpioI = em.import.@"em.hal/GpioI";

pub const EM__HOST = struct {
    pub const DbgA = em__C.DbgA.ref();
    pub const DbgB = em__C.DbgB.ref();
    pub const DbgC = em__C.DbgC.ref();
    pub const DbgD = em__C.DbgD.ref();
};

pub const EM__TARG = struct {
    //
    const DbgA = em__C.DbgA.scope();
    const DbgB = em__C.DbgB.scope();
    const DbgC = em__C.DbgC.scope();
    const DbgD = em__C.DbgD.scope();

    fn delay() void {
        Common.BusyWait.wait(1);
    }

    pub fn mark(comptime id: u8, k: u8) void {
        for (0..k + 1) |_| {
            pulse(id);
        }
    }

    pub fn minus(comptime id: u8) void {
        getDbg(id).set();
    }

    fn getDbg(comptime id: u8) type {
        switch (id) {
            'A' => return DbgA,
            'B' => return DbgB,
            'C' => return DbgC,
            'D' => return DbgD,
            else => return GpioI,
        }
    }

    pub fn plus(comptime id: u8) void {
        getDbg(id).clear();
    }

    pub fn pulse(comptime id: u8) void {
        const Dbg = getDbg(id);
        Dbg.toggle();
        delay();
        Dbg.toggle();
        delay();
    }

    pub fn reset() void {
        resetDbg('A');
        resetDbg('B');
        resetDbg('C');
        resetDbg('D');
    }

    fn resetDbg(comptime id: u8) void {
        const Dbg = getDbg(id);
        Dbg.reset();
    }

    pub fn startup() void {
        startDbg('A');
        startDbg('B');
        startDbg('C');
        startDbg('D');
    }

    fn startDbg(comptime id: u8) void {
        const Dbg = getDbg(id);
        Dbg.makeOutput();
        Dbg.set();
    }
};
