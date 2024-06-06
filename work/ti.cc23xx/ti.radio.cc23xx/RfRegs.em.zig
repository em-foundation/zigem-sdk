pub const em = @import("../../.gen/em.zig");
pub const em__unit = em.Module(@This(), .{});

pub const c_reg_init = em__unit.config("reg_init", em.Table(u16));

pub const EM__HOST = struct {
    //
    pub fn em__constructH() void {
        const hdr = @embedFile("rcl_settings.h");
        var pre_flag = true;
        var cur_addr: u16 = 0;
        var cur_val: u16 = 0;
        var it = em.std.mem.splitSequence(u8, hdr, "\n");
        _ = it.first();
        var tab = em.Table(u16){};
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
            const ln_addr = parseHex(col[1][2..]);
            //const ln_mod = col[2];
            const bits = col[4][1 .. col[4].len - 1];
            const val: u16 = if (em.std.mem.eql(u8, col[6], "<TRIM>")) 0 else parseHex(col[6][2..]);
            if (cur_addr != ln_addr) {
                if (cur_addr != 0) tab.add(cur_val);
                cur_addr = ln_addr;
                cur_val = 0;
            }
            const idx = em.std.mem.indexOf(u8, bits, ":");
            const hi_bit: u4 = @intCast(if (idx == null) parseDec(bits) else parseDec(bits[0..idx.?]));
            const lo_bit: u4 = @intCast(if (idx == null) hi_bit else parseDec(bits[idx.? + 1 ..]));
            cur_val |= (val << lo_bit);
        }
        tab.add(cur_val);
        c_reg_init.set(tab);
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
    const reg_init = c_reg_init.unwrap();

    pub fn em__run() void {
        em.print("len = {d}\n", .{reg_init.len});
    }
};
