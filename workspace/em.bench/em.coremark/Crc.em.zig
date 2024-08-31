pub const em = @import("../../build/.gen/em.zig");
pub const em__U = em.module(@This(), .{});

pub const Utils = em.import.@"em.coremark/Utils";
pub const sum_t = Utils.sum_t;

pub const EM__HOST = struct {};

pub const EM__TARG = struct {
    //
    pub fn add16(val: i16, old_crc: sum_t) sum_t {
        const v: u16 = @bitCast(val);
        var crc = old_crc;
        crc = update(@intCast(v), crc);
        crc = update(@intCast(v >> 8), crc);
        return crc;
    }

    pub fn add32(val: u32, old_crc: sum_t) sum_t {
        var crc = old_crc;
        crc = add16(@intCast(@as(i32, @bitCast(val))), crc);
        crc = add16(@intCast(@as(i32, @bitCast(val >> 16))), crc);
        return crc;
    }

    fn update(old_data: u8, old_crc: sum_t) sum_t {
        var i: u8 = 0;
        var x16: u8 = 0;
        var carry: u8 = 0;
        var crc = old_crc;
        var data = old_data;
        while (i < 8) : (i += 1) {
            x16 = @intCast((data & 1) ^ (crc & 1));
            data >>= 1;
            if (x16 == 1) {
                crc ^= 0x4002;
                carry = 1;
            } else {
                carry = 0;
            }
            crc >>= 1;
            if (carry != 0) {
                crc |= 0x8000;
            } else {
                crc &= 0x7fff;
            }
        }
        return crc;
    }
};

//package em.coremark
//
//import Utils
//
//module Crc
//
//    type sum_t: Utils.sum_t
//
//    function add16(val: int16, crc: sum_t): sum_t
//    function addU32(val: uint32, crc: sum_t): sum_t
//
//private:
//
//    function update(data: uint8, crc: sum_t): sum_t
//
//end
//
//def add16(val, crc)
//    auto v = <uint16>val
//    crc = update(<uint8>v, crc)
//    crc = update(<uint8>(v >> 8), crc)
//    return crc
//end
//
//def addU32(val, crc)
//    crc = add16(<int16>val, crc)
//    crc = add16(<int16>(val >> 16), crc)
//    return crc
//end
//
//def update(data, crc)
//    auto i = <uint8>0
//    auto x16 = <uint8>0
//    auto carry = <uint8>0
//    for auto i = 0; i < 8; i++
//        x16 = <uint8>((data & 1) ^ (<uint8>crc & 1))
//        data >>= 1
//        if x16 == 1
//            crc ^= 0x4002
//            carry = 1
//        else
//            carry = 0
//        end
//        crc >>= 1
//        if carry
//            crc |= 0x8000
//        else
//            crc &= 0x7fff
//        end
//    end
//    return crc
//end
//
