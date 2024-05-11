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
