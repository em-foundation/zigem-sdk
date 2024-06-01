pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const NUM_SEEDS: usize = 5;

pub const Kind = enum { FINAL, LIST, MATRIX, STATE, ZZZ_ };

pub const seed_t = u16;
pub const sum_t = u16;

pub var seed_tab = em__unit.array("seed_tab", seed_t);

pub const EM__HOST = struct {
    //
    pub fn em__initH() void {
        seed_tab.setLen(NUM_SEEDS);
    }

    pub fn bindSeedH(idx: u8, val: seed_t) void {
        seed_tab.unwrap()[idx - 1] = val;
    }
};

pub const EM__TARG = struct {
    //
    var crc_tab = em.std.mem.zeroes([@intFromEnum(Kind.ZZZ_)]sum_t);
    var v_seed_tab = seed_tab.unwrap();

    pub fn bindCrc(kind: Kind, crc: sum_t) void {
        const p = &crc_tab[@intFromEnum(kind)];
        if (p.* == 0) p.* = crc;
    }

    pub fn getCrc(kind: Kind) sum_t {
        return crc_tab[@intFromEnum(kind)];
    }

    pub fn getSeed(idx: u8) seed_t {
        const p: *volatile u16 = @constCast(&v_seed_tab[idx - 1]);
        return p.*;
    }

    pub fn setCrc(kind: Kind, crc: sum_t) void {
        crc_tab[@intFromEnum(kind)] = crc;
    }
};
