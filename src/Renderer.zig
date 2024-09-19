const std = @import("std");
const zls = @import("zls");

const Ast = std.zig.Ast;
const Fs = @import("Fs.zig");
const Heap = @import("Heap.zig");

pub fn exec(path: []const u8) !void {
    var ctx = try Context.init();
    defer ctx.deinit();

    std.log.debug("\n\n", .{});

    const uri = try ctx.addDocument(path);
    const params = types.SemanticTokensParams{
        .textDocument = .{ .uri = uri },
    };
    const response = try ctx.server.sendRequestSync(Heap.get(), "textDocument/semanticTokens/full", params) orelse {
        std.debug.print("Server returned `null` as the result\n", .{});
        return error.InvalidResponse;
    };

    var tok_str = SemTokStream.init(response.data);
    while (tok_str.next()) |tok| {
        std.log.debug("{d:>3},{d:>3}:    {s}", .{ tok.line, tok.col, @tagName(tok.ttype) });
    }
}

const builtin = @import("builtin");

const Config = zls.Config;
const Server = zls.Server;
const types = zls.types;

const default_config: Config = .{
    .semantic_tokens = .full,
    .enable_inlay_hints = false,
    .inlay_hints_exclude_single_argument = false,
    .inlay_hints_show_builtin = false,
    .zig_exe_path = null,
    .zig_lib_path = null,
    .global_cache_path = null,
};

const Context = struct {
    server: *Server,

    pub fn init() !Context {
        const server = try Server.create(Heap.get());
        errdefer server.destroy();

        try server.updateConfiguration2(default_config);

        var context: Context = .{
            .server = server,
        };

        _ = try context.server.sendRequestSync(Heap.get(), "initialize", .{ .capabilities = .{} });
        _ = try context.server.sendNotificationSync(Heap.get(), "initialized", .{});

        return context;
    }

    pub fn deinit(self: *Context) void {
        _ = self.server.sendRequestSync(Heap.get(), "shutdown", {}) catch unreachable;
        self.server.sendNotificationSync(Heap.get(), "exit", {}) catch unreachable;
        std.debug.assert(self.server.status == .exiting_success);
        self.server.destroy();
    }

    // helper
    pub fn addDocument(self: *Context, path: []const u8) ![]const u8 {
        const norm = try Fs.normalize(path);
        const source = Fs.readFileZ(norm);
        const uri = try std.fmt.allocPrint(
            Heap.get(),
            "file://{s}",
            .{norm},
        );
        const params = types.DidOpenTextDocumentParams{
            .textDocument = .{
                .uri = uri,
                .languageId = .{ .custom_value = "zig" }, // no zig :(
                .version = 420,
                .text = source,
            },
        };
        _ = try self.server.sendNotificationSync(Heap.get(), "textDocument/didOpen", params);
        return uri;
    }
};

const SemTokStream = struct {
    data: []const u32,
    idx: usize = 0,
    line_num: u32 = 1,
    col_num: u32 = 1,
    pub const Token = struct {
        ttype: zls.semantic_tokens.TokenType,
        line: u32,
        col: u32,
        len: u32,
        tmods: u32,
    };
    pub fn init(data: []const u32) SemTokStream {
        return SemTokStream{
            .data = data,
        };
    }
    pub fn next(self: *SemTokStream) ?Token {
        if (self.idx >= self.data.len) return null;
        const chunk = self.data[self.idx .. self.idx + 5];
        self.idx += 5;
        if (chunk[0] > 0) {
            self.line_num += chunk[0];
            self.col_num = 1;
        }
        self.col_num += chunk[1];
        const tok = Token{
            .line = self.line_num,
            .col = self.col_num,
            .len = chunk[2],
            .ttype = @enumFromInt(chunk[3]),
            .tmods = chunk[4],
        };
        return tok;
    }
};
