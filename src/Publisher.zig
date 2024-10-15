const std = @import("std");

const Fs = @import("./Fs.zig");
const Heap = @import("./Heap.zig");
const Out = @import("./Out.zig");

const print = std.debug.print;

pub fn exec(path: []const u8) !void {
    const norm = try Fs.normalize(path);
    const txt = Fs.readFileZ(norm);
    const mark = std.mem.indexOf(u8, txt, "//->>");
    const src = std.mem.trimRight(u8, if (mark) |m| txt[0..m] else txt, "\r\n");
    var digest: [32]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash(src, &digest, .{});
    const hbuf = std.fmt.bytesToHex(digest, .lower);
    if (mark) |m| {
        const suf = txt[m + 1 ..];
        const idx1 = std.mem.indexOf(u8, suf, "|").?;
        const idx2 = std.mem.indexOf(u8, suf[idx1 + 1 ..], "|").?;
        if (std.mem.eql(u8, &hbuf, suf[idx1..idx2])) return;
    }
    var file = try Out.open(norm);
    file.print("{s}\n\n//->> zigem publish #|{s}|#\n", .{ src, hbuf });
    file.close();
}

fn mkHash(src: []const u8) []const u8 {
    var digest: [32]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash(src, &digest, .{});
    return &std.fmt.bytesToHex(digest, .lower);
}

fn mkSuffix(src: []const u8) []const u8 {
    var sb = Out.StringBuf{};
    var digest: [32]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash(src, &digest, .{});
    const hs = std.fmt.bytesToHex(digest, .lower);
    sb.add(Out.sprint("//->> zigem publish: #{s}\n", .{hs}));
    return sb.get();
}
