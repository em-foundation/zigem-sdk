const std = @import("std");

const Fs = @import("./Fs.zig");
const Heap = @import("./Heap.zig");
const Out = @import("./Out.zig");

const print = std.debug.print;

var ast: std.zig.Ast = undefined;
var file: *Out.File = undefined;

pub fn exec(path: []const u8, force: bool) !void {
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
        const suf1 = suf[idx1 + 1 ..];
        const idx2 = std.mem.indexOf(u8, suf1, "|").?;
        const suf2 = suf1[0..idx2];
        if (!force and std.mem.eql(u8, &hbuf, suf2)) return;
    }
    const srcZ = try std.fmt.allocPrintZ(Heap.get(), "{s}", .{src});
    ast = try std.zig.Ast.parse(Heap.get(), srcZ, .zig);
    file = try Out.open(norm);
    const fmt =
        \\{s}
        \\
        \\//->> zigem publish #|{s}|#
        \\
        \\//->> generated source code -- do not modify
        \\//->> all of these lines can be safely deleted
        \\
    ;
    file.print(fmt, .{ src, hbuf });
    genDecls();
    file.close();
}

fn genDecls() void {
    for (ast.rootDecls()) |idx| {
        const node = ast.nodes.get(idx);
        switch (node.tag) {
            .simple_var_decl => {
                const tok = ast.tokenSlice(node.main_token);
                if (!std.mem.eql(u8, tok, "const")) continue;
                const d = ast.simpleVarDecl(idx);
                if (d.ast.mut_token == 0) continue;
                const mut = ast.tokenSlice(d.ast.mut_token - 1);
                if (!std.mem.eql(u8, mut, "pub")) continue;
                const name = ast.tokenSlice(node.main_token + 1);
                if (!std.mem.eql(u8, name, "EM__META") and !std.mem.eql(u8, name, "EM__TARG")) continue;
                walkScope(name, node.data.rhs);
            },
            else => {},
        }
    }
}

fn walkScope(sname: []const u8, idx: u32) void {
    file.print("\n//->> {s} publics\n", .{sname});
    const node = ast.nodes.get(idx);
    var scope: std.zig.Ast.full.ContainerDecl = undefined;
    switch (node.tag) {
        .container_decl, .container_decl_trailing => {
            scope = ast.containerDecl(idx);
        },
        .container_decl_two, .container_decl_two_trailing => {
            var buf: [2]u32 = undefined;
            scope = ast.containerDeclTwo(&buf, idx);
        },
        else => return,
    }
    for (scope.ast.members) |mem_idx| {
        const mem_decl = ast.nodes.get(mem_idx);
        if (!std.mem.eql(u8, ast.tokenSlice(mem_decl.main_token - 1), "pub")) continue;
        const dname = ast.tokenSlice(mem_decl.main_token + 1);
        if (std.mem.startsWith(u8, dname, "em__")) continue;
        file.print("pub const {0s} = {1s}.{0s};\n", .{ dname, sname });
    }
}
