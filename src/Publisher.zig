const std = @import("std");

const Fs = @import("./Fs.zig");
const Heap = @import("./Heap.zig");
const Out = @import("./Out.zig");

const Ast = std.zig.Ast;
const print = std.debug.print;

var ast: Ast = undefined;
var file: *Out.File = undefined;
var lines: std.ArrayList([]const u8) = undefined;
var members: []const Ast.Node.Index = undefined;
var tab: []const u8 = undefined;

pub fn exec(path: []const u8, force: bool) !void {
    const norm = try Fs.normalize(path);
    const txt = Fs.readFileZ(norm);
    const mark = std.mem.indexOf(u8, txt, "//->>");
    const src = if (mark) |m| txt[0..m] else txt;
    const srcZ = try std.fmt.allocPrintZ(Heap.get(), "{s}", .{src});
    ast = try Ast.parse(Heap.get(), srcZ, .zig);
    const ren_src = try ast.render(Heap.get());
    lines = try mkLines(ren_src);
    var digest: [32]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash(ren_src, &digest, .{});
    const hbuf = std.fmt.bytesToHex(digest, .lower);
    var done = false;
    if (mark) |m| {
        const suf = txt[m..];
        const idx1 = std.mem.indexOf(u8, suf, "|").?;
        const suf1 = suf[idx1 + 1 ..];
        const idx2 = std.mem.indexOf(u8, suf1, "|").?;
        const suf2 = suf1[0..idx2];
        done = !force and std.mem.eql(u8, &hbuf, suf2);
    }
    file = try Out.open(norm);
    const gen_idx = findDecl("em__generateS");
    if (gen_idx > 0) {
        const gen_fn = ast.nodes.get(gen_idx);
        const gen_body = ast.nodes.get(gen_fn.data.rhs);
        const gen_blk = ast.nodes.get(gen_body.data.lhs);
        members = ast.containerDecl(gen_blk.data.lhs).ast.members;
        tab = "        ";
    } else {
        members = ast.rootDecls();
        tab = "";
    }
    if (done) {
        file.print("{s}\n{s}", .{ ren_src, txt[mark.?..] });
    } else {
        file.print("{s}\n{s}//->> zigem publish #|{s}|#\n", .{ ren_src, tab, hbuf });
        genDecls();
        file.print("\n{s}//->> zigem publish -- end of generated code\n", .{tab});
    }
    file.close();
}

fn findDecl(dname: []const u8) Ast.Node.Index {
    for (ast.rootDecls()) |idx| {
        const decl = ast.nodes.get(idx);
        if (std.mem.eql(u8, ast.tokenSlice(decl.main_token + 1), dname)) return idx;
    }
    return 0;
}

fn genDecls() void {
    for (members) |idx| {
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

fn mkLines(txt: []const u8) !std.ArrayList([]const u8) {
    var res = std.ArrayList([]const u8).init(Heap.get());
    var iter = std.mem.splitScalar(u8, txt, '\n');
    while (iter.next()) |s| {
        try res.append(s);
    }
    return res;
}

fn walkScope(sname: []const u8, idx: u32) void {
    file.print("\n{s}//->> {s} publics\n", .{ tab, sname });
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
        file.print("{2s}pub const {0s} = {1s}.{0s};\n", .{ dname, sname, tab });
    }
}
