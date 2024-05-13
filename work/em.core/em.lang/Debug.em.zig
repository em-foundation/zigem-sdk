pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

const Common = em.Import.@"em.mcu/Common";
const GpioI = em.Import.@"em.hal/GpioI";

pub const x_DbgA = em__unit.proxy("DbgA", GpioI);
pub const x_DbgB = em__unit.proxy("DbgB", GpioI);
pub const x_DbgC = em__unit.proxy("DbgC", GpioI);
pub const x_DbgD = em__unit.proxy("DbgD", GpioI);

pub const EM__HOST = struct {};

pub const EM__TARG = struct {};

const DbgA = x_DbgA.unwrap();
const DbgB = x_DbgB.unwrap();
const DbgC = x_DbgC.unwrap();
const DbgD = x_DbgD.unwrap();

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
