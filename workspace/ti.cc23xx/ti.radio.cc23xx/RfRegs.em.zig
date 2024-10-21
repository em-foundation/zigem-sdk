pub const em = @import("../../zigem/em.zig");
pub const em__U = em.module(@This(), .{});
pub const em__C = em__U.config(EM__CONFIG);

pub const EM__CONFIG = struct {
    desc_tab: em.Table(Desc, .RO),
    val_tab: em.Table(u16, .RO),
};

pub const Desc = struct {
    off: u16,
    cnt: u8,
    inc: u8,
};

pub const RadioConfig = em.import.@"ti.radio.cc23xx/RadioConfig";

pub const EM__META = struct {
    //
    var desc_tab = em__C.desc_tab;
    var val_tab = em__C.val_tab;

    pub fn em__constructM() void {
        const regfile = switch (RadioConfig.c_phy.getM()) {
            .PROP_250K => @embedFile("regs_prop_250k.txt"),
            .BLE_1M => @embedFile("regs_ble_1m.txt"),
            else => return,
        };
        var pre_flag = true;
        var it = em.std.mem.splitSequence(u8, regfile, "\n");
        _ = it.first();
        while (it.next()) |ln| {
            if (pre_flag) {
                if (em.std.mem.startsWith(u8, ln, "// ----")) {
                    pre_flag = false;
                }
                continue;
            }
            if (!em.std.mem.startsWith(u8, ln, "//")) break;
            var it2 = em.std.mem.tokenizeScalar(u8, ln, ' ');
            var col: [7][]const u8 = undefined;
            for (0..col.len) |i| col[i] = it2.next().?;
            const addr = parseHex(col[1][2..]);
            const hwmod = col[2];
            const bits = col[4][1 .. col[4].len - 1];
            const val: u16 = if (em.std.mem.eql(u8, col[6], "-")) 0 else parseHex(col[6][2..]);
            Encoder.addM(addr, hwmod, bits, val);
        }
        Encoder.finalize();
    }

    const Encoder = struct {
        var cur_desc: Desc = undefined;
        var cur_hwmod: []const u8 = "";
        var cur_addr: u16 = 0;
        var cur_val: u16 = 0;
        var cur_serial: u16 = 0;
        var prev_addr: u16 = 0;
        pub fn addM(addr: u16, hwmod: []const u8, bits: []const u8, val: u16) void {
            if (!em.std.mem.eql(u8, cur_hwmod, hwmod)) {
                if (cur_hwmod.len != 0) {
                    flush();
                    desc_tab.addM(cur_desc);
                }
                cur_hwmod = hwmod;
                cur_desc.off = addr;
                cur_desc.cnt = 0;
                cur_desc.inc = if (em.std.mem.endsWith(u8, hwmod, "_RAM")) 1 else 2;
                cur_addr = addr;
                prev_addr = addr;
            }
            if (cur_addr != addr) {
                if (cur_addr != 0) flush();
                prev_addr = cur_addr;
                cur_addr = addr;
            }
            const idx = em.std.mem.indexOf(u8, bits, ":");
            const hi_bit = em.@"<>"(u4, if (idx == null) parseDec(bits) else parseDec(bits[0..idx.?]));
            const lo_bit = em.@"<>"(u4, if (idx == null) hi_bit else parseDec(bits[idx.? + 1 ..]));
            cur_val |= (val << lo_bit);
        }
        pub fn finalize() void {
            flush();
            desc_tab.addM(cur_desc);
        }

        fn flush() void {
            const diff = (cur_addr - prev_addr) >> em.@"<>"(u4, cur_desc.inc);
            if (diff > 1) {
                for (1..diff) |_| {
                    cur_serial += 1;
                    val_tab.addM(0);
                    cur_desc.cnt += 1;
                }
            }
            //em.print("[{d}] @{X:0>4} = {X:0>4} ({d})", .{ cur_serial, cur_addr, cur_val, diff });
            cur_serial += 1;
            val_tab.addM(cur_val);
            cur_val = 0;
            cur_desc.cnt += 1;
        }
    };

    fn parseHex(s: []const u8) u16 {
        return em.std.fmt.parseInt(u16, s, 16) catch unreachable;
    }

    fn parseDec(s: []const u8) u16 {
        return em.std.fmt.parseInt(u16, s, 10) catch unreachable;
    }
};

pub const EM__TARG = struct {
    //
    const desc_tab = em__C.desc_tab.items();
    const val_tab = em__C.val_tab.items();

    const LRF_BASE_ADDR: u32 = 0x40080000;
    const PBE_RAM_BASE_ADDR: u32 = 0x40090000;

    pub fn setup() void {
        var src: [*]const u16 = val_tab.ptr;
        for (desc_tab) |desc| {
            const base = if (desc.inc == 1) PBE_RAM_BASE_ADDR else LRF_BASE_ADDR;
            var dst: [*]u16 = @ptrFromInt(base + desc.off);
            for (0..desc.cnt) |_| {
                dst[0] = src[0];
                src += 1;
                dst += desc.inc;
            }
        }
    }
};


//->> zigem publish #|53abd4154bf23c06f9ce9add22bb93a7c1420d396152db9ae92c523cd192a989|#

//->> EM__META publics

//->> EM__TARG publics
pub const setup = EM__TARG.setup;

//->> zigem publish -- end of generated code
