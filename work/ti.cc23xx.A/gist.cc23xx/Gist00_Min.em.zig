const std = @import("std");

const em = @import("../../.gen/em.zig");
const me = @This();

const BusyWait = em.Unit.@"ti.mcu.cc23xx/BusyWait";
const Hal = em.Unit.@"ti.mcu.cc23xx/Hal";

pub const em__unit = em.UnitSpec{
    .kind = .module,
    .upath = "gist.cc23xx/Gist00_Min",
    .self = me,
};

//pub const em__imports = .{
//    BusyWait.em__unit,
//    Hal.em__unit,
//};

pub var c_max = em.Config(u8).init(10);

pub fn em__init() void {
    std.log.debug("em__init: {s}", .{me.em__unit.upath});
    c_max.set(20);
}

//pub fn em__declare() void {
//    //std.log.debug("{s}", .{@typeName(@TypeOf(c_max))});
//    //std.log.debug("{any}", .{@typeName(@TypeOf(c_max))});
//    //@compileLog(@typeInfo(@TypeOf(c_max)));
//    //inline for (@typeInfo(me).Struct.decls) |decl| {
//    //    const fld = @field(me, decl.name);
//    //    const ti = @typeInfo(@TypeOf(fld));
//    //    @compileLog(fld);
//    //    if (ti == .Struct and @hasDecl(@TypeOf(fld), "em__config")) {
//    //        //            std.log.debug("{s}", .{decl.name});
//    //    }
//    //}
//    //c_max.set(100);
//    //std.log.debug("em__declare: {any}", .{c_max.get()});
//    c_max.print();
//}
//
//pub fn em__run() void {
//    const REG = em.REG;
//    const pin = 15;
//    const mask = (1 << pin);
//    REG(Hal.GPIO_BASE + Hal.GPIO_O_DOESET31_0).* = mask;
//    REG(Hal.IOC_BASE + Hal.IOC_O_IOC0 + pin * 4).* &= ~Hal.IOC_IOC0_INPEN;
//    for (0..10) |_| {
//        BusyWait.wait(100000);
//        REG(Hal.GPIO_BASE + Hal.GPIO_O_DOUTTGL31_0).* = mask;
//    }
//    em.halt();
//}
