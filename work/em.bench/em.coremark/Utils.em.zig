pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const NUM_SEEDS: usize = 5;

pub const Kind = enum { FINAL, LIST, MATRIX, STATE, ZZZ_ };

pub const seed_t = u16;
pub const sum_t = u16;

pub var crc_tab = em__unit.array("crc_tab", sum_t);
pub var seed_tab = em__unit.array("seed_tab", seed_t);

pub const EM__HOST = struct {
    //
    pub fn em__initH() void {
        crc_tab.setLen(@intFromEnum(Kind.ZZZ_));
        seed_tab.setLen(NUM_SEEDS);
    }

    pub fn bindSeedH(idx: u8, val: seed_t) void {
        seed_tab.unwrap()[idx - 1] = val;
    }
};

pub const EM__TARG = struct {
    //
    var v_seed_tab = seed_tab.unwrap();

    pub fn bindCrc(kind: Kind, crc: sum_t) void {
        const p = &crc_tab.unwrap()[@intFromEnum(kind)];
        if (p.* == 0) p.* = crc;
    }

    pub fn getCrc(kind: Kind) sum_t {
        return crc_tab.unwrap()[@intFromEnum(kind)];
    }

    pub fn getSeed(idx: u8) seed_t {
        //var res = v_seed_tab[idx - 1];
        //const p: *volatile seed_t = &res;
        //return p.*;
        const p: *volatile u16 = @constCast(&v_seed_tab[idx - 1]);
        return p.*;
    }

    pub fn setCrc(kind: Kind, crc: sum_t) void {
        crc_tab.unwrap()[@intFromEnum(kind)] = crc;
    }
};

//package em.coremark
//
//module Utils
//
//    const NUM_SEEDS: uint8 = 5
//
//    type Kind: enum
//        FINAL, LIST, MATRIX, STATE, ZZZ_
//    end
//
//    type seed_t: uint16 volatile
//    type sum_t: uint16
//
//    function bindCrc(kind: Kind, crc: sum_t)
//    function getCrc(kind: Kind): sum_t
//    function setCrc(kind: Kind, crc: sum_t)
//
//    host function bindSeedH(idx: uint8, val: seed_t)
//    function getSeed(idx: uint8): seed_t
//
//private:
//
//    var crcTab: sum_t[]
//    var seedTab: seed_t[NUM_SEEDS]
//
//end
//
//def em$construct()
//    crcTab.length = <uint16>Kind.ZZZ_
//end
//
//def bindCrc(kind, crc)
//    auto p = &crcTab[<uint16>kind]
//    *p = crc if *p == 0
//end
//
//def bindSeedH(idx, val)
//    seedTab[idx - 1] = val
//end
//
//def getCrc(kind)
//    return crcTab[<uint16>kind]
//end
//
//def getSeed(idx)
//    return seedTab[idx - 1]
//end
//
//def setCrc(kind, crc)
//    crcTab[<uint16>kind] = crc
//end
//
