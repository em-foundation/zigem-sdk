pub const EM__SPEC = null;

pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{
    .inherits = em.Import.@"em.coremark/BenchAlgI",
});

pub const Utils = em.Import.@"em.coremark/Utils";

pub const c_memsize = em__unit.config("memsize", u16);

pub const EM__HOST = null;

pub var a_membuf = em__unit.array("a_membuf", u8);

pub var a_errpat = em__unit.array("a_errpat", []const u8);
pub var a_fltpat = em__unit.array("a_fltpat", []const u8);
pub var a_intpat = em__unit.array("a_intpat", []const u8);
pub var a_scipat = em__unit.array("a_scipat", []const u8);

pub const c_errpat_len = em__unit.config("errpat_len", usize);
pub const c_fltpat_len = em__unit.config("fltpat_len", usize);
pub const c_intpat_len = em__unit.config("intpat_len", usize);
pub const c_scipat_len = em__unit.config("scipat_len", usize);

const errpat_vals = [_][]const u8{ "T0.3e-1F", "-T.T++Tq", "1T3.4e4z", "34.0e-T^" };
const fltpat_vals = [_][]const u8{ "35.54400", ".1234500", "-110.700", "+0.64400" };
const intpat_vals = [_][]const u8{ "5012", "1234", "-874", "+122" };
const scipat_vals = [_][]const u8{ "5.500e+3", "-.123e-2", "-87e+832", "+0.6e-12" };

pub fn em__initH() void {
    for (errpat_vals) |v| a_errpat.addElem(v);
    for (fltpat_vals) |v| a_fltpat.addElem(v);
    for (intpat_vals) |v| a_intpat.addElem(v);
    for (scipat_vals) |v| a_scipat.addElem(v);
}

pub fn em__constructH() void {
    a_membuf.setLen(c_memsize.get());
    c_errpat_len.set(a_errpat.getElem(0).*.len);
    c_fltpat_len.set(a_fltpat.getElem(0).*.len);
    c_intpat_len.set(a_intpat.getElem(0).*.len);
    c_scipat_len.set(a_scipat.getElem(0).*.len);
}

pub const EM__TARG = null;

const State = enum {
    START,
    INVALID,
    S1,
    S2,
    INT,
    FLOAT,
    EXPONENT,
    SCIENTIFIC,
};

const NUM_STATES = @typeInfo(State).Enum.fields.len;

const memsize = c_memsize.unwrap();

const errpat_len = c_errpat_len.unwrap();
const fltpat_len = c_fltpat_len.unwrap();
const intpat_len = c_intpat_len.unwrap();
const scipat_len = c_scipat_len.unwrap();

var membuf = a_membuf.unwrap();

pub fn dump() void {
    // TODO
    return;
}

pub fn kind() Utils.Kind {
    return .STATE;
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

pub fn setup() void { //    auto seed = Utils.getSeed(1)
    //    auto p = &memBuf[0]
    //    auto total = 0
    //    auto pat = ""
    //    auto plen = 0
    //    while (total + plen + 1) < (memSize - 1)
    //        if plen
    //            for auto i = 0; i < plen; i++
    //                *p++ = pat[i]
    //            end
    //            *p++ = ','
    //            total += plen + 1
    //        end
    //        switch ++seed & 0x7
    //        case 0
    //        case 1
    //        case 2
    //            pat  = intPat[(seed >> 3) & 0x3]
    //            plen = intPatLen
    //            break
    //        case 3
    //        case 4
    //            pat  = fltPat[(seed >> 3) & 0x3]
    //            plen = fltPatLen
    //            break
    //        case 5
    //        case 6
    //            pat  = sciPat[(seed >> 3) & 0x3]
    //            plen = sciPatLen
    //            break
    //        case 7
    //            pat  = errPat[(seed >> 3) & 0x3]
    //            plen = errPatLen
    //            break
    //        end
    //    end
    //end
}

//package em.coremark
//
//import BenchAlgI
//import Crc
//import Utils
//
//# patterned after core_state.c
//
//module StateBench: BenchAlgI
//
//private:
//
//    const NUM_STATES: uint8 = 8
//
//    type StringBuf: char*
//
//    type State: enum
//        START,
//        INVALID,
//        S1,
//        S2,
//        INT,
//        FLOAT,
//        EXPONENT,
//        SCIENTIFIC,
//    end
//
//    config intPat: string[4] = [
//        "5012", "1234", "-874", "+122"
//    ]
//    config fltPat: string[4] = [
//        "35.54400", ".1234500", "-110.700", "+0.64400"
//    ]
//    config sciPat: string[4] = [
//        "5.500e+3", "-.123e-2", "-87e+832", "+0.6e-12"
//    ]
//    config errPat: string[4] = [
//        "T0.3e-1F", "-T.T++Tq", "1T3.4e4z", "34.0e-T^"
//    ]
//
//    config intPatLen: uint16
//    config fltPatLen: uint16
//    config sciPatLen: uint16
//    config errPatLen: uint16
//
//    var memBuf: char[]
//
//    function isDigit(ch: char): bool
//    function nextState(pStr: StringBuf*, transCnt: uint32[]): State
//    function ord(state: State): uint8
//    function scan(finalCnt: uint32[], transCnt: uint32[])
//    function scramble(seed: Utils.seed_t, step: uarg_t)
//
//end
//
//def em$construct()
//    memBuf.length = memSize
//    intPatLen = intPat[0].length
//    fltPatLen = fltPat[0].length
//    sciPatLen = sciPat[0].length
//    errPatLen = errPat[0].length
//end
//
//def dump()
//    ## TODO -- implement
//end
//
//def isDigit(ch)
//    return ch >= '0' && ch <= '9'
//end
//
//def kind()
//    return Utils.Kind.STATE
//end
//
//def nextState(pStr, transCnt)
//    auto str = *pStr
//    auto state = State.START
//    for ; *str && state != State.INVALID; str++
//        auto ch = *str
//        if ch == ','
//            str++
//            break
//        end
//        switch state
//        case State.START
//            if isDigit(ch)
//                state = State.INT
//            elif ch == '+' || ch == '-'
//                state = State.S1
//            elif ch == '.'
//                state = State.FLOAT
//            else
//                state = State.INVALID
//                transCnt[ord(State.INVALID)] += 1
//            end
//            transCnt[ord(State.START)] += 1
//            break
//        case State.S1
//            if isDigit(ch)
//                state = State.INT
//                transCnt[ord(State.S1)] += 1
//            elif ch == '.'
//                state = State.FLOAT
//                transCnt[ord(State.S1)] += 1
//            else
//                state = State.INVALID
//                transCnt[ord(State.S1)] += 1
//            end
//            break
//        case State.INT
//            if ch == '.'
//                state = State.FLOAT
//                transCnt[ord(State.INT)] += 1
//            elif !isDigit(ch)
//                state = State.INVALID
//                transCnt[ord(State.INT)] += 1
//            end
//            break
//        case State.FLOAT
//            if ch == 'E' || ch == 'e'
//                state = State.S2
//                transCnt[ord(State.FLOAT)] += 1
//            elif !isDigit(ch)
//                state = State.INVALID
//                transCnt[ord(State.FLOAT)] += 1
//            end
//            break
//        case State.S2
//            if ch == '+' || ch == '-'
//                state = State.EXPONENT
//                transCnt[ord(State.S2)] += 1
//            else
//                state = State.INVALID
//                transCnt[ord(State.S2)] += 1
//            end
//            break
//        case State.EXPONENT
//            if isDigit(ch)
//                state = State.SCIENTIFIC
//                transCnt[ord(State.EXPONENT)] += 1
//            else
//                state = State.INVALID
//                transCnt[ord(State.EXPONENT)] += 1
//            end
//            break
//        case State.SCIENTIFIC
//            if !isDigit(ch)
//                state = State.INVALID
//                transCnt[ord(State.INVALID)] += 1
//            end
//            break
//        end
//    end
//    *pStr = str
//    return state
//end
//
//def ord(state)
//    return <uint8>state
//end
//
//def print()
//    auto p = &memBuf[0]
//    auto cnt = 0
//    printf "\n%c", '"'
//    while *p
//        if (cnt++ % 8) == 0
//            printf "\n    "
//        end
//        var c: char
//        while (c = *p++) != ','
//            printf "%c", c
//        end
//        printf ", "
//    end
//    printf "\n%c, count = %d\n", '"', cnt
//end
//
//def run(arg)
//    arg = 0x22 if arg < 0x22
//    var finalCnt: uint32[NUM_STATES]
//    var transCnt: uint32[NUM_STATES]
//    for auto i = 0; i < NUM_STATES; i++
//        finalCnt[i] = transCnt[i] = 0
//    end
//    scan(finalCnt, transCnt)
//    scramble(Utils.getSeed(1), arg)
//    scan(finalCnt, transCnt)
//    scramble(Utils.getSeed(2), arg)
//    auto crc = Utils.getCrc(Utils.Kind.FINAL)
//    for auto i = 0; i < NUM_STATES; i++
//        crc = Crc.addU32(finalCnt[i], crc)
//        crc = Crc.addU32(transCnt[i], crc)
//    end
//    return crc
//end
//
//def scan(finalCnt, transCnt)
//    for auto str = &memBuf[0]; *str;
//        auto state = nextState(&str, transCnt)
//        finalCnt[ord(state)] += 1
//    end
//end
//
//def scramble(seed, step)
//    for auto str = &memBuf[0]; str < &memBuf[memSize]; str += <uint16>step
//        *str ^= <uint8>seed if *str != ','
//    end
//end
//
//def setup()
//    auto seed = Utils.getSeed(1)
//    auto p = &memBuf[0]
//    auto total = 0
//    auto pat = ""
//    auto plen = 0
//    while (total + plen + 1) < (memSize - 1)
//        if plen
//            for auto i = 0; i < plen; i++
//                *p++ = pat[i]
//            end
//            *p++ = ','
//            total += plen + 1
//        end
//        switch ++seed & 0x7
//        case 0
//        case 1
//        case 2
//            pat  = intPat[(seed >> 3) & 0x3]
//            plen = intPatLen
//            break
//        case 3
//        case 4
//            pat  = fltPat[(seed >> 3) & 0x3]
//            plen = fltPatLen
//            break
//        case 5
//        case 6
//            pat  = sciPat[(seed >> 3) & 0x3]
//            plen = sciPatLen
//            break
//        case 7
//            pat  = errPat[(seed >> 3) & 0x3]
//            plen = errPatLen
//            break
//        end
//    end
//end
//
