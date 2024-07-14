pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{
    .inherits = em.Import.@"em.coremark/BenchAlgI",
});

pub const Crc = em.Import.@"em.coremark/Crc";
pub const ListBench = em.Import.@"em.coremark/ListBench";
pub const MatrixBench = em.Import.@"em.coremark/MatrixBench";
pub const StateBench = em.Import.@"em.coremark/StateBench";
pub const Utils = em.Import.@"em.coremark/Utils";

pub const NUM_ALGS: u8 = 3;
pub const TOTAL_DATA_SIZE: u16 = 2000;

pub const EM__HOST = struct {
    //
    pub fn em__configureH() void {
        const memsize = TOTAL_DATA_SIZE / NUM_ALGS;
        ListBench.c_memsize.set(memsize);
        MatrixBench.c_memsize.set(memsize);
        StateBench.c_memsize.set(memsize);
    }

    pub fn em__constructH() void {
        Utils.bindSeedH(1, 0x0);
        Utils.bindSeedH(2, 0x0);
        Utils.bindSeedH(3, 0x66);
    }
};

pub const EM__TARG = struct {
    //
    pub fn dump() void {
        ListBench.dump();
        MatrixBench.dump();
        StateBench.dump();
    }

    pub fn kind() Utils.Kind {
        return .FINAL;
    }

    pub fn print() void {
        em.print("\n*** CoreBench.print\n", .{});
        ListBench.print();
        MatrixBench.print();
        StateBench.print();
    }

    pub fn run(_: i16) Utils.sum_t {
        var crc = ListBench.run(1);
        Utils.setCrc(.FINAL, Crc.add16(@bitCast(crc), Utils.getCrc(.FINAL)));
        crc = ListBench.run(-1);
        Utils.setCrc(.FINAL, Crc.add16(@bitCast(crc), Utils.getCrc(.FINAL)));
        Utils.bindCrc(.LIST, Utils.getCrc(.FINAL));
        return Utils.getCrc(.FINAL);
    }

    pub fn setup() void {
        ListBench.setup();
        MatrixBench.setup();
        StateBench.setup();
    }
};

//package em.coremark
//
//from em.lang import Math
//
//import BenchAlgI
//import Crc
//import ListBench
//import IdxComparator
//import MatrixBench
//import StateBench
//import Utils
//import ValComparator
//
//module CoreBench: BenchAlgI
//
//    config TOTAL_DATA_SIZE: uint16 = 2000
//    config NUM_ALGS: uint8 = 3
//
//end
//
//def em$configure()
//    memSize = Math.floor(TOTAL_DATA_SIZE / NUM_ALGS)
//    ListBench.idxCompare ?= IdxComparator.compare
//    ListBench.valCompare ?= ValComparator.compare
//    ListBench.memSize ?= memSize
//    MatrixBench.memSize ?= memSize
//    StateBench.memSize ?= memSize
//    ValComparator.Bench0 ?= StateBench
//    ValComparator.Bench1 ?= MatrixBench
//end
//
//def em$construct()
//    Utils.bindSeedH(1, 0x0)
//    Utils.bindSeedH(2, 0x0)
//    Utils.bindSeedH(3, 0x66)
//end
//
//def dump()
//    ListBench.dump()
//    MatrixBench.dump()
//    StateBench.dump()
//end
//
//def kind()
//    return Utils.Kind.FINAL
//end
//
//def print()
//    ListBench.print()
//    MatrixBench.print()
//    StateBench.print()
//end
//
//def run(arg)
//    auto crc = ListBench.run(1)
//    Utils.setCrc(Utils.Kind.FINAL, Crc.add16(<int16>crc, Utils.getCrc(Utils.Kind.FINAL)))
//    crc = ListBench.run(-1)
//    Utils.setCrc(Utils.Kind.FINAL, Crc.add16(<int16>crc, Utils.getCrc(Utils.Kind.FINAL)))
//    Utils.bindCrc(Utils.Kind.LIST, Utils.getCrc(Utils.Kind.FINAL))
//    return Utils.getCrc(Utils.Kind.FINAL)
//end
//
//def setup()
//    ListBench.setup()
//    MatrixBench.setup()
//    StateBench.setup()
//end
//
