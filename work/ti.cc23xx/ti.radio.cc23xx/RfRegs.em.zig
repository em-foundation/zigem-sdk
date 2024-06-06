pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const Desc = struct {
    off: u16,
    cnt: u8,
    inc: u8,
};

pub const c_desc_tab = em__unit.config("desc_tab", em.Table(Desc));
pub const c_val_tab = em__unit.config("val_tab", em.Table(u16));

pub const EM__HOST = struct {
    //
    pub fn em__constructH() void {
        const hdr = @embedFile("rcl_settings.h");
        var pre_flag = true;
        var cur_desc: Desc = undefined;
        var cur_hwmod: []const u8 = "";
        var cur_addr: u16 = 0;
        var cur_val: u16 = 0;
        var it = em.std.mem.splitSequence(u8, hdr, "\n");
        _ = it.first();
        var desc_tab = em.Table(Desc){};
        var val_tab = em.Table(u16){};
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
            const val: u16 = if (em.std.mem.eql(u8, col[6], "<TRIM>")) 0 else parseHex(col[6][2..]);
            if (!em.std.mem.eql(u8, cur_hwmod, hwmod)) {
                if (cur_hwmod.len != 0) desc_tab.add(cur_desc);
                cur_hwmod = hwmod;
                cur_desc.off = addr;
                cur_desc.cnt = 0;
                cur_desc.inc = if (em.std.mem.endsWith(u8, hwmod, "_RAM")) 1 else 2;
            }
            if (cur_addr != addr) {
                if (cur_addr != 0) {
                    val_tab.add(cur_val);
                    cur_desc.cnt += 1;
                }
                cur_addr = addr;
                cur_val = 0;
            }
            const idx = em.std.mem.indexOf(u8, bits, ":");
            const hi_bit: u4 = @intCast(if (idx == null) parseDec(bits) else parseDec(bits[0..idx.?]));
            const lo_bit: u4 = @intCast(if (idx == null) hi_bit else parseDec(bits[idx.? + 1 ..]));
            cur_val |= (val << lo_bit);
        }
        val_tab.add(cur_val);
        cur_desc.cnt += 1;
        desc_tab.add(cur_desc);
        c_desc_tab.set(desc_tab);
        c_val_tab.set(val_tab);
    }

    fn parseHex(s: []const u8) u16 {
        return em.std.fmt.parseInt(u16, s, 16) catch unreachable;
    }

    fn parseDec(s: []const u8) u16 {
        return em.std.fmt.parseInt(u16, s, 10) catch unreachable;
    }
};

pub const EM__TARG = struct {
    //
    const desc_tab = c_desc_tab.unwrap();
    const val_tab = c_val_tab.unwrap();

    const LRF_BASE_ADDR: u32 = 0x40080000;
    const PBE_RAM_BASE_ADDR: u32 = 0x40090000;

    pub fn em__run() void {
        setup();
    }

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
