pub const EM__SPEC = null;

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{
    .inherits = em.Import.@"em.coremark/BenchAlgI",
});

pub const Utils = em.Import.@"em.coremark/Utils";

pub const c_memsize = em__unit.config("memsize", u16);

pub const EM__HOST = null;

pub const EM__TARG = null;

pub fn dump() void {
    // TODO
    return;
}

pub fn kind() Utils.Kind {
    return .MATRIX;
}

pub fn print() void {
    // TODO
    return;
}

pub fn run(arg: i16) Utils.sum_t {
    // TODO
    _ = arg;
    return 0;
}

pub fn setup() void {
    // TODO
    return;
}

//package em.coremark
//
//import BenchAlgI
//import Crc
//import Utils
//
//# patterned after core_matrix.c
//
//module MatrixBench: BenchAlgI
//
//private:
//
//    type matdat_t: int16
//    type matres_t: int32
//
//    config dimN: uint8
//
//    var matA: matdat_t[]
//    var matB: matdat_t[]
//    var matC: matres_t[]
//
//    function addVal(val: matdat_t)
//    function mulVal(val: matdat_t)
//    function mulMat()
//    function mulMatBix()
//    function mulVec()
//    function sumDat(clipval: matdat_t): matdat_t
//
//    function bix(res: matres_t, lower: uint8, upper: uint8): matres_t
//    function clip(d: matdat_t, b: bool): matdat_t
//    function enlarge(val: matdat_t): matdat_t
//
//    function prDat(lab: string, mat: matdat_t[])
//    function prRes(lab: string)
//
//end
//
//def em$construct()
//    auto i = 0
//    auto j = 0
//    while j < memSize
//        i += 1
//        j = i * i * 2 * 4
//    end
//    dimN = i - 1
//    matA.length = matB.length = matC.length = dimN * dimN
//end
//
//def addVal(val)
//    for auto i = 0; i < dimN; i++
//        for auto j = 0; j < dimN; j++
//            matA[i * dimN + j] += val
//        end
//    end
//end
//
//def bix(res, lower, upper)
//    auto r = <uint32>res
//    auto l = <uint32>lower
//    auto u = <uint32>upper
//    return <matres_t>((r >> l) & (~(0xffffffff << u)))
//end
//
//def clip(d, b)
//    auto x = <uint16>d
//    return <matdat_t>(x & (b ? 0x0ff : 0x0ffff))
//end
//
//def dump()
//    ## TODO -- implement
//end
//
//def enlarge(val)
//    auto v = <uint16>val
//    return <matdat_t>(0xf000 | v)
//end
//
//def kind()
//    return Utils.Kind.MATRIX
//end
//
//def mulVal(val)
//    for auto i = 0; i < dimN; i++
//        for auto j = 0; j < dimN; j++
//            matC[i * dimN + j] = <matres_t>matA[i * dimN + j] * <matres_t>val
//        end
//    end
//end
//
//def mulMat()
//    for auto i = 0; i < dimN; i++
//        for auto j = 0; j < dimN; j++
//            matC[i * dimN + j] = 0
//            for auto k = 0; k < dimN; k++
//                matC[i * dimN + j] += <matres_t>matA[i * dimN + k] * <matres_t>matB[k * dimN + j]
//            end
//        end
//    end
//end
//
//def mulMatBix()
//    for auto i = 0; i < dimN; i++
//        for auto j = 0; j < dimN; j++
//            matC[i * dimN + j] = 0
//            for auto k = 0; k < dimN; k++
//                auto tmp = <matres_t>matA[i * dimN + k] * <matres_t>matB[k * dimN + j]
//                matC[i * dimN + j] += bix(tmp, 2, 4) * bix(tmp, 5, 7)
//            end
//        end
//    end
//end
//
//def mulVec()
//    for auto i = 0; i < dimN; i++
//        matC[i] = 0
//        for auto j = 0; j < dimN; j++
//            matC[i] += <matres_t>matA[i * dimN + j] * <matres_t>matB[j]
//        end
//    end
//end
//
//def print()
//    prDat("A", matA)
//    prDat("B", matB)
//end
//
//def prDat(lab, mat)
//    printf "\n%s:\n    ", lab
//    for auto i = 0; i < dimN; i++
//        auto sep = ""
//        for auto j = 0; j < dimN; j++
//            printf "%s%d", sep, mat[i * dimN + j]
//            sep = ","
//        end
//        printf "\n    "
//    end
//end
//
//def prRes(lab)
//    printf "\n%s:\n    ", lab
//    for auto i = 0; i < dimN; i++
//        auto sep = ""
//        for auto j = 0; j < dimN; j++
//            printf "%s%d", sep, matC[i * dimN + j]
//            sep = ","
//        end
//        printf "\n    "
//    end
//end
//
//def run(arg)
//    auto crc = <Crc.sum_t>0
//    auto val = <matdat_t>arg
//    auto clipval = enlarge(val)
//    #
//    addVal(val)
//    mulVal(val)
//    crc = Crc.add16(sumDat(clipval), crc)
//    #
//    mulVec()
//    crc = Crc.add16(sumDat(clipval), crc)
//    #
//    mulMat()
//    crc = Crc.add16(sumDat(clipval), crc)
//    #
//    mulMatBix()
//    crc = Crc.add16(sumDat(clipval), crc)
//    #
//    addVal(-val)
//    return Crc.add16(<int16>crc, Utils.getCrc(Utils.Kind.FINAL))
//end
//
//def setup()
//    auto s32 = <uint32>Utils.getSeed(1) | (<uint32>Utils.getSeed(2) << 16)
//    auto sd = <matdat_t>s32
//    sd = 1 if sd == 0
//    auto order = <matdat_t>1
//    for auto i = 0; i < dimN; i++
//        for auto j = 0; j < dimN; j++
//            sd = <int16>((order * sd) % 65536)
//            auto val = <matdat_t>(sd + order)
//            val = clip(val, false)
//            matB[i * dimN + j] = val
//            val += order
//            val = clip(val, true)
//            matA[i * dimN + j] = val
//            order += 1
//        end
//    end
//end
//
//def sumDat(clipval)
//    auto cur = <matres_t>0
//    auto prev = <matres_t>0
//    auto tmp = <matres_t>0
//    auto ret = <matdat_t>0
//    for auto i = 0; i < dimN; i++
//        for auto j = 0; j < dimN; j++
//            cur = matC[i * dimN + j]
//            tmp += cur
//            if tmp > clipval
//                ret += 10
//                tmp = 0
//            else
//                ret += (cur > prev) ? 1 : 0
//            end
//            prev = cur
//        end
//    end
//    return ret
//end
//
