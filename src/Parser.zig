const std = @import("std");

const AstUtils = @import("AstUtils.zig");

const print = std.debug.print;

pub fn exec(path: []const u8) !void {
    const ast = try AstUtils.parse(path);
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
                print("pub const {s}\n", .{name});
            },
            else => {},
        }
    }
    // var iter = AstUtils.NodeIter.init(&ast);
    // while (try iter.next()) |val| {
    //     if (val.direction != .down) continue;
    //     const node = ast.nodes.get(val.idx);
    //     switch (node.tag) {
    //         .simple_var_decl => {
    //             const tok = ast.tokenSlice(node.main_token);
    //             if (!std.mem.eql(u8, tok, "const")) continue;
    //             const d = ast.simpleVarDecl(val.idx);
    //             if (d.ast.mut_token != 1) continue;
    //             const name = ast.tokenSlice(node.main_token + 1);
    //             print("pub const {s}\n", .{name});
    //         },
    //         else => {},
    //     }
    // }
}
