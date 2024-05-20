pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{
    .inherits = em.Import.@"em.coremark/BenchAlgI",
});

pub const Crc = em.Import.@"em.coremark/Crc";
pub const Utils = em.Import.@"em.coremark/Utils";

pub const Data = struct {
    val: i16 = 0,
    idx: i16 = 0,
};

pub const Elem = struct {
    next: em.Ref(Elem),
    data: em.Ref(Data),
};

pub const Comparator = fn (a: em.Ref(Data), b: em.Ref(Data)) i32;

pub const c_memsize = em__unit.config("memsize", u16);

pub const v_cur_head = em__unit.config("cur_head", em.Ref(Elem));
pub const v_max_elems = em__unit.config("max_elems", u16);

pub const a_data = em__unit.array("a_data", Data);
pub const a_elem = em__unit.array("a_elem", Elem);

fn getD(ref: em.Ref(Data)) *Data {
    return a_data.get(ref).?;
}

fn getE(ref: em.Ref(Elem)) *Elem {
    return a_elem.get(ref).?;
}

fn getED(ref: em.Ref(Elem)) *Data {
    return getD((getE(ref).data));
}

pub const EM__HOST = struct {
    //
    pub fn em__constructH() void {
        const item_size = 16 + @sizeOf(Data);
        const max = @as(u16, @intFromFloat(@round(@as(f32, @floatFromInt(c_memsize.get())) / @as(f32, @floatFromInt(item_size))))) - 3;
        const head = a_elem.alloc(.{});
        getE(head).data = a_data.alloc(.{});
        var p = head;
        for (0..max - 1) |_| {
            const q = a_elem.alloc(.{});
            getE(q).data = a_data.alloc(.{});
            getE(p).next = q;
            p = q;
        }
        getE(p).next = em.Ref_NIL(Elem);
        v_cur_head.set(head);
        v_max_elems.set(max);
    }
};

pub const EM__TARG = struct {
    //
    var cur_head = v_cur_head.unwrap();
    const max_elems = v_max_elems.unwrap();

    pub fn dump() void {
        // TODO
        return;
    }

    fn find(list: em.Ref(Elem), data: em.Ref(Data)) em.Ref(Elem) {
        var elem = list;
        if (getD(data).idx >= 0) {
            while (!elem.isNil() and getED(elem).idx != getD(data).idx) {
                elem = getE(elem).next;
            }
        } else {
            const idx: i16 = @bitCast(@as(u16, @bitCast(getED(elem).idx)) & @as(u16, 0xff));
            while (!elem.isNil() and (idx != getD(data).idx)) {
                elem = getE(elem).next;
            }
        }
        return elem;
    }

    pub fn kind() Utils.Kind {
        return .LIST;
    }

    fn prList(list: em.Ref(Elem), name: []const u8) void {
        var sz: usize = 0;
        em.print("{s}\n[", .{name});
        var p = list;
        while (!p.isNil()) {
            const pre: []const u8 = if ((sz % 8) == 0) "\n    " else "";
            sz += 1;
            em.print("{s}({x:0>4},{x:0>4})", .{ pre, @as(u16, @bitCast(getED(p).idx)), @as(u16, @bitCast(getED(p).val)) });
            p = getE(p).next;
        }
        em.print("\n], size = {d}\n", .{sz});
    }

    pub fn print() void {
        prList(cur_head, "current");
    }

    fn remove(item: em.Ref(Elem)) em.Ref(Elem) {
        const ret = getE(item).next;
        const tmp = getE(item).data;
        getE(item).data = getE(ret).next;
        getE(ret).data = tmp;
        getE(item).next = getE(getE(item).next).next;
        getE(ret).next = em.Ref_NIL(Elem);
    }

    fn reverse(list: em.Ref(Elem)) em.Ref(Elem) {
        var p = list;
        var next = em.Ref_NIL(Elem);
        while (!p.isNil()) {
            const tmp = getE(p).next;
            getE(p).next = next;
            next = p;
            p = tmp;
        }
    }

    pub fn run(arg: i16) Utils.sum_t {
        //var list = cur_head;
        //var finder_idx = arg;
        //var find_cnt = Utils.getSeed(3);
        //var data: Data = undefined;
        //for (0..find_cnt) |i| {
        //    data.val = @bitCast(i & 0xff);
        //}

        return arg;
        //return Crc.add16(arg, Utils.getSeed(2));
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

    }

    pub fn setup() void {
        const seed = Utils.getSeed(1);
        var ki: u16 = 1;
        var kd: u16 = max_elems - 3;
        var e = cur_head;
        getED(e).idx = 0;
        getED(e).val = @bitCast(@as(u16, 0x8080));
        e = getE(e).next;
        while (!getE(e).next.isNil()) : (e = getE(e).next) {
            var pat = (seed ^ kd) & 0xf;
            const dat = (pat << 3) | (kd & 0x7);
            getED(e).val = @bitCast((dat << 8) | dat);
            kd -= 1;
            if (ki < (max_elems / 5)) {
                getED(e).idx = @bitCast(ki);
                ki += 1;
            } else {
                pat = seed ^ ki;
                ki += 1;
                getED(e).idx = @bitCast(@as(u16, 0x3fff) & (((ki & 0x7) << 8) | pat));
            }
        }
        getED(e).idx = @bitCast(@as(u16, 0x7fff));
        getED(e).val = @bitCast(@as(u16, 0xffff));
        em.@"%%[c+]"();
        cur_head = sort(cur_head, idxCompare);
        em.@"%%[c-]"();
    }

    fn sort(list: em.Ref(Elem), cmp: Comparator) em.Ref(Elem) {
        var res = list;
        var insize: usize = 1;
        var q: em.Ref(Elem) = undefined;
        var e: em.Ref(Elem) = undefined;
        while (true) {
            var p = res;
            res = em.Ref_NIL(Elem);
            var tail = em.Ref_NIL(Elem);
            var nmerges: i32 = 0; // count number of merges we do in this pass
            while (!p.isNil()) {
                nmerges += 1; // there exists a merge to be done
                // step `insize' places along from p
                q = p;
                var psize: usize = 0;
                for (0..insize) |_| {
                    psize += 1;
                    q = getE(q).next;
                    if (q.isNil()) break;
                }
                // if q hasn't fallen off end, we have two lists to merge
                var qsize: usize = insize;
                // now we have two lists; merge them
                while (psize > 0 or (qsize > 0 and !q.isNil())) {
                    // decide whether next element of merge comes from p or q
                    if (psize == 0) {
                        // p is empty; e must come from q
                        e = q;
                        q = getE(q).next;
                        qsize -= 1;
                    } else if (qsize == 0 or q.isNil()) {
                        // q is empty; e must come from p.
                        e = p;
                        p = getE(p).next;
                        psize -= 1;
                    } else if (cmp(getE(p).data, getE(q).data) <= 0) {
                        // First element of p is lower (or same); e must come from p.
                        e = p;
                        p = getE(p).next;
                        psize -= 1;
                    } else {
                        // First element of q is lower; e must come from q.
                        e = q;
                        q = getE(q).next;
                        qsize -= 1;
                    }
                    // add the next element to the merged list
                    if (!tail.isNil()) {
                        getE(tail).next = e;
                    } else {
                        res = e;
                    }
                    tail = e;
                }
                // now p has stepped `insize' places along, and q has too
                p = q;
            }
            getE(tail).next = em.Ref_NIL(Elem);
            // If we have done only one merge, we're finished
            if (nmerges <= 1) break; // allow for nmerges==0, the empty list case
            // Otherwise repeat, merging lists twice the size
            insize *= 2;
        }
        return res;
    }

    fn unremove(removed: em.Ref(Elem), modified: em.Ref(Elem)) void {
        const tmp = getE(removed).data;
        getE(removed).data = getE(modified).data;
        getE(modified).data = tmp;
        getE(removed).next = getE(modified).next;
        getE(modified).next = removed;
    }

    // Comparator

    fn idxCompare(a: em.Ref(Data), b: em.Ref(Data)) i32 {
        const avu: u16 = @bitCast(getD(a).val);
        const bvu: u16 = @bitCast(getD(b).val);
        const sft: u4 = 8;
        const mhi: u16 = 0xff00;
        const mlo: u16 = 0x00ff;
        getD(a).val = @bitCast((avu & mhi) | (mlo & (avu >> sft)));
        getD(b).val = @bitCast((bvu & mhi) | (mlo & (bvu >> sft)));
        return getD(a).idx - getD(b).idx;
    }
};

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
