pub const EM__SPEC = null;

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const NUM_SEEDS: usize = 5;

pub const Kind = enum { FINAL, LIST, MATRIX, STATE, ZZZ_ };

pub const seed_t = u16;
pub const sum_t = u16;

pub const crc_tab = em__unit.array("crc_tab", sum_t);
pub const seed_tab = em__unit.array("seed_tab", seed_t);

pub const EM__HOST = null;

pub fn em__initH() void {
    for (0..@intFromEnum(Kind.ZZZ_)) |_| crc_tab.addElem(0);
    for (0..NUM_SEEDS) |_| seed_tab.addElem(0);
}

pub fn bindSeedH(idx: u8, val: seed_t) void {
    seed_tab.unwrap()[idx - 1] = val;
}

pub const EM__TARG = null;

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
