pub const EM__SPEC = null;

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{
    .inherits = em.Import.@"em.coremark/BenchAlgI",
});

pub const Crc = em.Import.@"em.coremark/Crc";
pub const Utils = em.Import.@"em.coremark/Utils";

pub const c_memsize = em__unit.config("memsize", u16);

pub const EM__HOST = struct {};

pub const EM__TARG = struct {};

pub fn dump() void {
    // TODO
    return;
}

pub fn kind() Utils.Kind {
    return .LIST;
}

pub fn print() void {
    // TODO
    return;
}

pub fn run(arg: i16) Utils.sum_t {
    return Crc.add16(arg, Utils.getSeed(2));
}

pub fn setup() void {
    // TODO
    return;
}

//package em.coremark
//
//from em.lang import Math
//
//import BenchAlgI
//import Crc
//import Utils
//
//# patterned after core_list_join.c
//
//module ListBench: BenchAlgI
//
//    type Data: struct
//        val: int16
//        idx: int16
//    end
//
//    type Comparator: function(a: Data&, b: Data&): int32
//
//    config idxCompare: Comparator
//    config valCompare: Comparator
//
//private:
//
//    type Elem: struct
//        next: Elem&
//        data: Data&
//    end
//
//    function find(list: Elem&, data: Data&): Elem&
//    function pr(list: Elem&, name: string)
//    function remove(item: Elem&): Elem&
//    function reverse(list: Elem&): Elem&
//    function sort(list: Elem&, cmp: Comparator): Elem&
//    function unremove(removed: Elem&, modified: Elem&)
//
//    config maxElems: uint16
//
//    var curHead: Elem&
//
//end
//
//def em$construct()
//    auto itemSize = 16 + sizeof<Data>
//    maxElems = Math.round(memSize / itemSize) - 3
//    curHead = new<Elem>
//    curHead.data = new<Data>
//    auto p = curHead
//    for auto i = 0; i < maxElems - 1; i++
//        auto q = p.next = new<Elem>
//        q.data = new<Data>
//        p = q
//    end
//    p.data = new<Data>
//    p.next = null
//end
//
//def dump()
//    for auto e = curHead; e; e = e.next
//        %%[a+]
//        %%[>e.data.idx]
//        %%[>e.data.val]
//        %%[a-]
//    end
//end
//
//def find(list, data)
//    auto elem = list
//    if data.idx >= 0
//        while elem && elem.data.idx != data.idx
//            elem = elem.next
//        end
//    else
//        while elem && <int16>(<uint16>elem.data.val & 0xff) != data.val
//            elem = elem.next
//        end
//    end
//    return elem
//end
//
//def kind()
//    return Utils.Kind.LIST
//end
//
//def pr(list, name)
//    auto sz = 0
//    printf "%s\n[", name
//    for auto e = list; e; e = e.next
//        auto pre = (sz++ % 8) == 0 ? "\n    " : ""
//        printf "%s(%04x,%04x)", <iarg_t>pre, e.data.idx, e.data.val
//    end
//    printf "\n], size = %d\n", sz
//end
//
//def print()
//    pr(curHead, "current")
//end
//
//def remove(item)
//    auto ret = item.next
//    auto tmp = item.data
//    item.data = ret.data
//    ret.data = tmp
//    item.next = item.next.next
//    ret.next = null
//    return ret
//end
//
//def reverse(list)
//    auto next = <Elem&>null
//    while list
//        auto tmp = list.next
//        list.next = next
//        next = list
//        list = tmp
//    end
//    return next
//end
//
// def run(arg)
//    auto list = curHead
//    auto finderIdx = <int16>arg
//    auto findCnt = Utils.getSeed(3)
//    auto found = <uint16>0
//    auto missed = <uint16>0
//    auto retval = <Crc.sum_t>0
//    var data: Data
//    data.idx = finderIdx
//    for auto i = 0; i < findCnt; i++
//        data.val = <int16>(i & 0xff)
//        auto elem = find(list, data)
//        list = reverse(list)
//        if elem == null
//            missed += 1
//            retval += <uint16>(list.next.data.val >> 8) & 0x1
//        else
//            found += 1
//            if <uint16>elem.data.val & 0x1
//                retval += (<uint16>(elem.data.val >> 9)) & 0x1
//            end
//            if elem.next != null
//                auto tmp = elem.next
//                elem.next = tmp.next
//                tmp.next = list.next
//                list.next = tmp
//            end
//        end
//        data.idx += 1 if data.idx >= 0
//    end
//    retval += found * 4 - missed
//    list = sort(list, valCompare) if finderIdx > 0
//    auto remover = remove(list.next)
//    auto finder = find(list, &data)
//    finder = list.next if !finder
//    while finder
//        retval = Crc.add16(list.data.val, retval)
//        finder = finder.next
//    end
//    unremove(remover, list.next)
//    list = sort(list, idxCompare)
//    for auto e = list.next; e; e = e.next
//        retval = Crc.add16(list.data.val, retval)
//    end
//    return retval
//end
//
//def setup()
//    auto seed = Utils.getSeed(1)
//    auto ki = 1
//    auto kd = maxElems - 3
//    auto e = curHead
//    e.data.idx = 0
//    e.data.val = 0x8080
//    for e = e.next; e.next; e = e.next
//        auto pat = <uint16>(seed ^ kd) & 0xf
//        auto dat = (pat << 3) | (kd & 0x7)
//        e.data.val = <int16>((dat << 8) | dat)
//        kd -= 1
//        if ki < (maxElems / 5)
//            e.data.idx = ki++
//        else
//            pat = <uint16>(seed ^ ki++)
//            e.data.idx = <int16>(0x3fff & (((ki & 0x7) << 8) | pat))
//        end
//    end
//    e.data.idx = 0x7fff
//    e.data.val = 0xffff
//    curHead = sort(curHead, idxCompare)
//end
//
//def sort(list, cmp)
//    auto insize = <int32>1
//    var q: Elem&
//    var e: Elem&
//    for ;;
//        auto p = list
//        auto tail = list = null
//        auto nmerges = <int32>0  # count number of merges we do in this pass
//        while p
//            nmerges++  # there exists a merge to be done
//            # step `insize' places along from p
//            q = p
//            auto psize = 0
//            for auto i = 0; i < insize; i++
//                psize++
//                q = q.next
//                break if !q
//            end
//            # if q hasn't fallen off end, we have two lists to merge
//            auto qsize = insize
//            # now we have two lists; merge them
//            while psize > 0 || (qsize > 0 && q)
//                # decide whether next element of merge comes from p or q
//                if psize == 0
//                    # p is empty; e must come from q
//                    e = q
//                    q = q.next
//                    qsize--
//                elif qsize == 0 || !q
//                    # q is empty; e must come from p.
//                    e = p
//                    p = p.next
//                    psize--
//                elif cmp(p.data, q.data) <= 0
//                    # First element of p is lower (or same); e must come from p.
//                    e = p
//                    p = p.next
//                    psize--
//                else
//                    # First element of q is lower; e must come from q.
//                    e = q
//                    q = q.next
//                    qsize--
//                end
//                # add the next element to the merged list
//                if tail
//                    tail.next = e
//                else
//                    list = e
//                end
//                tail = e
//            end
//            # now p has stepped `insize' places along, and q has too
//            p = q
//        end
//        tail.next = null
//        # If we have done only one merge, we're finished
//        break if nmerges <= 1  # allow for nmerges==0, the empty list case
//        # Otherwise repeat, merging lists twice the size
//        insize *= 2
//    end
//    return list
//end
//
//def unremove(removed, modified)
//    auto tmp = removed.data
//    removed.data = modified.data
//    modified.data = tmp
//    removed.next = modified.next
//    modified.next = removed
//end
