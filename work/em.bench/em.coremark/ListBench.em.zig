pub const em = @import("../../.gen/em.zig");
pub const em__U = em.module(@This(), .{
    .inherits = em.import.@"em.coremark/BenchAlgI",
});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    cur_head: em.Obj(Elem),
    max_elems: em.Param(u16),
    memsize: em.Param(u16),
    DataOF: em.Factory(Data),
    ElemOF: em.Factory(Elem),
};

pub const Common = em.import.@"em.mcu/Common";
pub const Crc = em.import.@"em.coremark/Crc";
pub const Utils = em.import.@"em.coremark/Utils";

const Bench0 = em.import.@"em.coremark/StateBench";
const Bench1 = em.import.@"em.coremark/MatrixBench";

pub const Data = struct {
    val: i16 = 0,
    idx: i16 = 0,
};

pub const Elem = struct {
    next: ?em.Obj(Elem),
    data: em.Obj(Data),
};

pub const Comparator = fn (a: em.Obj(Data), b: em.Obj(Data)) i32;

pub const EM__HOST = struct {
    //
    pub const memsize = em__C.memsize.ref();

    pub fn em__constructH() void {
        const item_size = 16 + @sizeOf(Data);
        const max = @as(u16, @intFromFloat(@round(@as(f32, @floatFromInt(em__C.memsize.get())) / @as(f32, @floatFromInt(item_size))))) - 3;
        const head = em__C.ElemOF.createH(.{});
        head.O().data = em__C.DataOF.createH(.{});
        var p = head;
        for (0..max - 1) |_| {
            const q = em__C.ElemOF.createH(.{});
            q.O().data = em__C.DataOF.createH(.{});
            p.O().next = q;
            p = q;
        }
        p.O().next = null;
        em__C.cur_head = head;
        em__C.max_elems.set(max);
    }
};

pub const EM__TARG = struct {
    //
    const max_elems = em__C.max_elems;

    var cur_head = em__C.cur_head;

    pub fn dump() void {
        // TODO
        return;
    }

    fn find(list: em.Obj(Elem), data: em.Obj(Data)) ?em.Obj(Elem) {
        var elem: ?em.Obj(Elem) = list;
        if (data.idx >= 0) {
            while (elem != null and (elem.?.data.idx != data.idx)) {
                elem = elem.?.next;
            }
        } else {
            while (elem != null) {
                const v: i16 = @bitCast(@as(u16, @bitCast(elem.?.data.val)) & @as(u16, 0xff));
                if (v == data.val) break;
                elem = elem.?.next;
            }
        }
        return elem;
    }

    pub fn kind() Utils.Kind {
        return .LIST;
    }

    fn prList(list: em.Obj(Elem), name: []const u8) void {
        var elem: ?em.Obj(Elem) = list;
        var sz: usize = 0;
        em.print("{s}\n[", .{name});
        while (elem != null) {
            const pre: []const u8 = if ((sz % 8) == 0) "\n    " else "";
            sz += 1;
            em.print("{s}({x:0>4},{x:0>4})", .{ pre, @as(u16, @bitCast(elem.?.data.idx)), @as(u16, @bitCast(elem.?.data.val)) });
            elem = elem.?.next;
        }
        em.print("\n], size = {d}\n", .{sz});
    }

    pub fn print() void {
        prList(cur_head, "current");
    }

    fn remove(item: em.Obj(Elem)) em.Obj(Elem) {
        const ret = item.next;
        const tmp = item.data;
        item.data = ret.?.data;
        ret.?.data = tmp;
        item.next = item.next.?.next;
        ret.?.next = null;
        return ret.?;
    }

    fn reverse(list: em.Obj(Elem)) em.Obj(Elem) {
        var p: ?em.Obj(Elem) = list;
        var next: ?em.Obj(Elem) = null;
        while (p != null) {
            const tmp = p.?.next;
            p.?.next = next;
            next = p;
            p = tmp;
        }
        return next.?;
    }

    pub fn run(arg: i16) Utils.sum_t {
        // em.@"%%[a+]"();
        var list = cur_head;
        const finder_idx = arg;
        const find_cnt = Utils.getSeed(3);
        var found: u16 = 0;
        var missed: u16 = 0;
        var retval: Crc.sum_t = 0;
        var data = Data{ .idx = finder_idx };
        var i: u16 = 0;
        while (i < find_cnt) : (i += 1) {
            data.val = @bitCast(i & 0xff);
            var elem = find(list, &data);
            list = reverse(list);
            if (elem == null) {
                missed += 1;
                const v: u16 = @bitCast(list.next.?.data.val);
                retval += (v >> 8) & 0x1;
            } else {
                found += 1;
                const v: u16 = @bitCast(elem.?.data.val);
                if ((v & 0x1) != 0) {
                    retval += (v >> 9) & 0x1;
                }
                if (elem.?.next != null) {
                    const tmp = elem.?.next;
                    elem.?.next = tmp.?.next;
                    tmp.?.next = list.next;
                    list.next = tmp;
                }
            }
            if (data.idx >= 0) data.idx += 1;
        }
        retval += found * 4 - missed;
        if (finder_idx > 0) list = sort(list, valCompare);
        const remover = remove(list.next.?);
        var finder = find(list, &data);
        if (finder == null) finder = list.next;
        while (finder != null) {
            retval = Crc.add16(list.data.val, retval);
            finder = finder.?.next;
        }
        unremove(remover, list.next.?);
        list = sort(list, idxCompare);
        var e = list.next;
        while (e != null) : (e = e.?.next) {
            retval = Crc.add16(list.data.val, retval);
        }
        // em.@"%%[a-]"();
        return retval;
    }

    pub fn setup() void {
        const seed = Utils.getSeed(1);
        var ki: u16 = 1;
        var kd: u16 = max_elems - 3;
        var e: ?em.Obj(Elem) = cur_head;
        e.?.data.idx = 0;
        e.?.data.val = @bitCast(@as(u16, 0x8080));
        e = e.?.next;
        var cnt: u8 = 0;
        while (e.?.next != null) : (e = e.?.next) {
            var pat = (seed ^ kd) & 0xf;
            const dat = (pat << 3) | (kd & 0x7);
            e.?.data.val = @bitCast((dat << 8) | dat);
            kd -= 1;
            if (ki < (max_elems / 5)) {
                e.?.data.idx = @bitCast(ki);
                ki += 1;
            } else {
                pat = seed ^ ki;
                ki += 1;
                e.?.data.idx = @bitCast(@as(u16, 0x3fff) & (((ki & 0x7) << 8) | pat));
            }
            cnt += 1;
        }
        e.?.data.idx = @bitCast(@as(u16, 0x7fff));
        e.?.data.val = @bitCast(@as(u16, 0xffff));
        em.@"%%[c+]"();
        cur_head = sort(cur_head, idxCompare);
        em.@"%%[c-]"();
    }

    fn sort(list: em.Obj(Elem), cmp: Comparator) em.Obj(Elem) {
        var res: ?em.Obj(Elem) = list;
        var insize: usize = 1;
        var q: ?em.Obj(Elem) = undefined;
        var e: em.Obj(Elem) = undefined;
        while (true) {
            var p = res;
            res = null;
            var tail: ?em.Obj(Elem) = null;
            var nmerges: i32 = 0; // count number of merges we do in this pass
            while (p != null) {
                nmerges += 1; // there exists a merge to be done
                // step `insize' places along from p
                q = p;
                var psize: usize = 0;
                for (0..insize) |_| {
                    psize += 1;
                    q = q.?.next;
                    if (q == null) break;
                }
                // if q hasn't fallen off end, we have two lists to merge
                var qsize: usize = insize;
                // now we have two lists; merge them
                while (psize > 0 or (qsize > 0 and q != null)) {
                    // decide whether next element of merge comes from p or q
                    if (psize == 0) {
                        // p is empty; e must come from q
                        e = q.?;
                        q = q.?.next;
                        qsize -= 1;
                    } else if (qsize == 0 or q == null) {
                        // q is empty; e must come from p.
                        e = p.?;
                        p = p.?.next;
                        psize -= 1;
                    } else if (cmp(p.?.data, q.?.data) <= 0) {
                        // First element of p is lower (or same); e must come from p.
                        e = p.?;
                        p = p.?.next;
                        psize -= 1;
                    } else {
                        // First element of q is lower; e must come from q.
                        e = q.?;
                        q = q.?.next;
                        qsize -= 1;
                    }
                    // add the next element to the merged list
                    if (tail != null) {
                        tail.?.next = e;
                    } else {
                        res = e;
                    }
                    tail = e;
                }
                // now p has stepped `insize' places along, and q has too
                p = q;
            }
            tail.?.next = null;
            // If we have done only one merge, we're finished
            if (nmerges <= 1) break; // allow for nmerges==0, the empty list case
            // Otherwise repeat, merging lists twice the size
            insize *= 2;
        }
        return res.?;
    }

    fn unremove(removed: em.Obj(Elem), modified: em.Obj(Elem)) void {
        const tmp = removed.data;
        removed.data = modified.data;
        modified.data = tmp;
        removed.next = modified.next;
        modified.next = removed;
    }

    // IdxComparator

    fn idxCompare(a: em.Obj(Data), b: em.Obj(Data)) i32 {
        const avu: u16 = @bitCast(a.val);
        const bvu: u16 = @bitCast(b.val);
        const sft: u4 = 8;
        const mhi: u16 = 0xff00;
        const mlo: u16 = 0x00ff;
        a.val = @bitCast((avu & mhi) | (mlo & (avu >> sft)));
        b.val = @bitCast((bvu & mhi) | (mlo & (bvu >> sft)));
        return a.idx - b.idx;
    }

    // ValComparator

    fn valCompare(a: em.Obj(Data), b: em.Obj(Data)) i32 {
        const val1 = valCmpCalc(&a.val);
        const val2 = valCmpCalc(&b.val);
        // em.print("z: vcmp = {d}\n", .{val1 - val2});
        return @intCast(val1 - val2);
    }

    fn valCmpCalc(pval: *i16) i16 {
        const val: u16 = @bitCast(pval.*);
        const optype: u8 = @as(u8, @intCast(val >> 7)) & 0x1;
        if (optype != 0) return @bitCast(val & 0x007f);
        const flag = val & 0x7;
        var vtype = (val >> 3) & 0xf;
        vtype |= vtype << 4;
        var ret: u16 = undefined;
        switch (flag) {
            0 => {
                ret = Bench0.run(@bitCast(vtype));
                Utils.bindCrc(Bench0.kind(), ret);
            },
            1 => {
                ret = Bench1.run(@bitCast(vtype));
                Utils.bindCrc(Bench1.kind(), ret);
            },
            else => {
                ret = val;
            },
        }
        Utils.setCrc(.FINAL, Crc.add16(@bitCast(ret), Utils.getCrc(.FINAL)));
        ret &= 0x007f;
        pval.* = @bitCast((val & 0xff00) | 0x0080 | ret);
        return @bitCast(ret);
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
