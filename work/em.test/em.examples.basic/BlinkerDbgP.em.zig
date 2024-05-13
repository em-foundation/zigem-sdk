pub const EM__SPEC = null;

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const BoardC = em.Import.@"em__distro/BoardC";
pub const Common = em.Import.@"em.mcu/Common";

pub const c_dbg_flag = em__unit.config("dbg_flag", bool);
pub const c_min_cnt = em__unit.config("min_cnt", u16);
pub const c_max_cnt = em__unit.config("max_cnt", u16);

pub const EM__HOST = struct {};

pub fn em__initH() void {
    c_dbg_flag.init(true);
    c_min_cnt.init(1000);
    c_max_cnt.init(1020);
}

pub const EM__TARG = struct {};

const AppLed = BoardC.AppLed;
const dbg_flag = c_dbg_flag.unwrap();
const min_cnt = c_min_cnt.unwrap();
const max_cnt = c_max_cnt.unwrap();

pub fn em__run() void {
    AppLed.on();
    for (min_cnt..max_cnt) |cnt| {
        em.@"%%[d+]"();
        Common.BusyWait.wait(250_000);
        em.@"%%[d-]"();
        AppLed.toggle();
        if (!dbg_flag) continue;
        //if (cnt > ((min_cnt + max_cnt) / 2)) em.fail();
        const bits11: u8 = @intCast(cnt & 0b0011);
        em.@"%%[c:]"(bits11);
        em.@"%%[>]"(bits11);
        em.print("cnt = {d} (0x{x:0>4}), bits11 = {d}", .{ cnt, cnt, bits11 });
    }
    AppLed.off();
}
