pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{
    .inherits = em.Import.@"em.coremark/BenchAlgI",
});

pub const Crc = em.Import.@"em.coremark/Crc";
pub const Utils = em.Import.@"em.coremark/Utils";

pub const c_memsize = em__unit.config("memsize", u16);

pub const EM__HOST = struct {};

pub const a_membuf = em__unit.array("a_membuf", u8);

pub const a_errpat = em__unit.array("a_errpat", []const u8);
pub const a_fltpat = em__unit.array("a_fltpat", []const u8);
pub const a_intpat = em__unit.array("a_intpat", []const u8);
pub const a_scipat = em__unit.array("a_scipat", []const u8);

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

pub const EM__TARG = struct {};

const StringBuf = [*]u8;

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

const errpat = a_errpat.unwrap();
const fltpat = a_fltpat.unwrap();
const intpat = a_intpat.unwrap();
const scipat = a_scipat.unwrap();

const errpat_len = c_errpat_len.unwrap();
const fltpat_len = c_fltpat_len.unwrap();
const intpat_len = c_intpat_len.unwrap();
const scipat_len = c_scipat_len.unwrap();

var membuf = if (!em.hosted) a_membuf.unwrap() else [_]u8{0};

pub fn dump() void {
    // TODO
    return;
}

fn isDigit(ch: u8) bool {
    return em.std.ascii.isDigit(ch);
}

pub fn kind() Utils.Kind {
    return .STATE;
}

fn nextState(pstr: *StringBuf, transcnt: [*]u32) State {
    var str = pstr.*;
    var state = State.START;
    while (str[0] != 0 and state != State.INVALID) : (str += 1) {
        const ch = str[0];
        if (ch == ',') {
            str += 1;
            break;
        }
        switch (state) {
            .INVALID => {},
            .START => {
                if (isDigit(ch)) {
                    state = .INT;
                } else if (ch == '+' or ch == '-') {
                    state = .S1;
                } else if (ch == '.') {
                    state = .FLOAT;
                } else {
                    state = .INVALID;
                    transcnt[ord(.INVALID)] += 1;
                }
                transcnt[ord(.START)] += 1;
            },
            .S1 => {
                if (isDigit(ch)) {
                    state = .INT;
                    transcnt[ord(.S1)] += 1;
                } else if (ch == '.') {
                    state = .FLOAT;
                    transcnt[ord(.S1)] += 1;
                } else {
                    state = .INVALID;
                    transcnt[ord(.S1)] += 1;
                }
            },
            .INT => {
                if (ch == '.') {
                    state = .FLOAT;
                    transcnt[ord(.INT)] += 1;
                } else if (!isDigit(ch)) {
                    state = .INVALID;
                    transcnt[ord(.INT)] += 1;
                }
            },
            .FLOAT => {
                if (ch == 'E' or ch == 'e') {
                    state = .S2;
                    transcnt[ord(.FLOAT)] += 1;
                } else if (!isDigit(ch)) {
                    state = .INVALID;
                    transcnt[ord(.FLOAT)] += 1;
                }
            },
            .S2 => {
                if (ch == '+' or ch == '-') {
                    state = .EXPONENT;
                    transcnt[ord(.S2)] += 1;
                } else {
                    state = .INVALID;
                    transcnt[ord(.S2)] += 1;
                }
            },
            .EXPONENT => {
                if (isDigit(ch)) {
                    state = .SCIENTIFIC;
                    transcnt[ord(.EXPONENT)] += 1;
                } else {
                    state = .INVALID;
                    transcnt[ord(.EXPONENT)] += 1;
                }
            },
            .SCIENTIFIC => {
                if (!isDigit(ch)) {
                    state = .INVALID;
                    transcnt[ord(.SCIENTIFIC)] += 1;
                }
            },
        }
    }
    pstr.* = str;
    return state;
}

fn ord(state: State) usize {
    return @intFromEnum(state);
}

pub fn print() void {
    // TODO
    return;
}

pub fn run(arg: i16) Utils.sum_t {
    if (em.hosted) return 0;
    var uarg: usize = @intCast(@as(u16, @bitCast(arg)));
    if (arg < 0x22) uarg = 0x22;
    var finalcnt: [NUM_STATES]u32 = undefined;
    var transcnt: [NUM_STATES]u32 = undefined;
    for (0..NUM_STATES) |i| {
        finalcnt[i] = 0;
        transcnt[i] = 0;
    }
    scan(&finalcnt, &transcnt);
    scramble(Utils.getSeed(1), uarg);
    scan(&finalcnt, &transcnt);
    scramble(Utils.getSeed(2), uarg);
    var crc = Utils.getCrc(Utils.Kind.FINAL);
    for (0..NUM_STATES) |i| {
        crc = Crc.add32(finalcnt[i], crc);
        crc = Crc.add32(transcnt[i], crc);
    }
    em.reg(0x2222).* = crc;
    return crc;
}

fn scan(finalcnt: [*]u32, transcnt: [*]u32) void {
    var str: [*]u8 = &membuf;
    while (str[0] != 0) {
        const state = nextState(&str, transcnt);
        finalcnt[ord(state)] += 1;
    }
}

fn scramble(seed: Utils.seed_t, step: usize) void {
    var idx: usize = 0;
    while (idx < memsize) : (idx += step) {
        if (membuf[idx] != ',') membuf[idx] ^= @as(u8, @intCast(seed));
    }
}

pub fn setup() void {
    if (em.hosted) return;
    var seed = Utils.getSeed(1);
    var idx = @as(usize, 0);
    var total = @as(usize, 0);
    var pat: []const u8 = "";
    var plen = @as(usize, 0);
    while ((total + plen + 1) < (memsize - 1)) {
        if (plen > 0) {
            for (0..plen) |i| {
                membuf[idx] = pat[i];
                idx += 1;
            }
            membuf[idx] = ',';
            idx += 1;
            total += plen + 1;
            seed += 1;
            switch (@as(u3, @intCast(seed & 0x7))) {
                0, 1, 2 => {
                    pat = intpat[(seed >> 3) & 0x3];
                    plen = intpat_len;
                },
                3, 4 => {
                    pat = fltpat[(seed >> 3) & 0x3];
                    plen = fltpat_len;
                },
                5, 6 => {
                    pat = scipat[(seed >> 3) & 0x3];
                    plen = scipat_len;
                },
                7 => {
                    pat = errpat[(seed >> 3) & 0x3];
                    plen = errpat_len;
                },
            }
        }
    }
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
