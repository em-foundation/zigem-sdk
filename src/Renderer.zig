const std = @import("std");
const zls = @import("zls");

const Fs = @import("Fs.zig");
const Heap = @import("Heap.zig");
const Out = @import("Out.zig");

const builtin = @import("builtin");

const types = zls.types;

const Annotator = struct {
    //
    pub const Item = struct {
        line: usize,
        pos: usize,
        code: u8,
    };

    allocator: std.mem.Allocator,
    item_list: std.ArrayList(Item),

    pub fn init(allocator: std.mem.Allocator) Annotator {
        return Annotator{
            .allocator = allocator,
            .item_list = std.ArrayList(Item).init(allocator),
        };
    }

    pub fn deinit(self: *Annotator) void {
        self.item_list.deinit();
    }

    pub fn addItem(self: *Annotator, item: Item) !void {
        try self.item_list.append(item);
    }

    pub fn applyItems(self: Annotator, src: []const u8) ![]const u8 {
        var last: usize = 0;
        var src_lines = SrcLines.init(self.allocator);
        defer src_lines.deinit();
        try src_lines.addSrc(src);
        var sb = Out.StringBuf{};
        for (self.item_list.items) |item| {
            const cur = src_lines.getOffset(item.line) + item.pos;
            sb.fmt("{s}#{c}", .{ src[last..cur], item.code });
            last = cur;
        }
        sb.fmt("{s}\n", .{src[last..]});
        return sb.get();
    }

    pub fn print(self: Annotator) void {
        for (self.item_list.items) |item| {
            std.debug.print("item({c}, {d}, {d})\n", .{ item.code, item.line, item.pos });
        }
    }
};

const Context = struct {
    //
    const Config = zls.Config;
    const Server = zls.Server;

    const default_config: Config = .{
        .semantic_tokens = .partial,
        .enable_inlay_hints = false,
        .inlay_hints_exclude_single_argument = false,
        .inlay_hints_show_builtin = false,
        .zig_exe_path = null,
        .zig_lib_path = null,
        .global_cache_path = null,
    };

    allocator: std.mem.Allocator,
    server: *Server,
    // source: [:0]const u8 = &[_:0]u8{},
    source: []const u8 = &[_]u8{},
    uri: []const u8 = &[_]u8{},

    pub fn init(allocator: std.mem.Allocator) !Context {
        const server = try Server.create(allocator);
        errdefer server.destroy();
        try server.updateConfiguration2(default_config);
        var ctx: Context = .{
            .allocator = allocator,
            .server = server,
        };
        _ = try ctx.server.sendRequestSync(allocator, "initialize", .{ .capabilities = .{} });
        _ = try ctx.server.sendNotificationSync(allocator, "initialized", .{});
        return ctx;
    }

    pub fn deinit(self: *Context) void {
        _ = self.server.sendRequestSync(self.allocator, "shutdown", {}) catch unreachable;
        self.server.sendNotificationSync(self.allocator, "exit", {}) catch unreachable;
        std.debug.assert(self.server.status == .exiting_success);
        self.server.destroy();
    }

    pub fn addDoc(self: *Context, path: []const u8) !void {
        const norm = try Fs.normalize(path);
        var uri_path = norm;
        if (builtin.target.os.tag == .windows) {
            var buf = try self.allocator.alloc(u8, norm.len + 2);
            var idx: usize = 0;
            for (norm) |c| {
                if (c == ':') {
                    buf[idx + 0] = '%';
                    buf[idx + 1] = '3';
                    buf[idx + 2] = 'A';
                    idx += 3;
                    continue;
                }
                buf[idx] = if (c == '\\') '/' else c;
                idx += 1;
            }
            uri_path = buf;
        }
        self.uri = try std.fmt.allocPrint(
            self.allocator,
            "file:///{s}",
            .{uri_path},
        );
        self.source = Fs.readFileZ(norm);
        if (std.mem.indexOf(u8, self.source, "//->> zigem publish")) |idx| {
            self.source = self.source[0..idx];
        }
        self.source = std.mem.trim(u8, self.source, &std.ascii.whitespace);
        const params = types.DidOpenTextDocumentParams{
            .textDocument = .{
                .uri = self.uri,
                .languageId = .{ .custom_value = "zig" }, // no zig :(
                .version = 420,
                .text = self.source,
            },
        };
        _ = try self.server.sendNotificationSync(self.allocator, "textDocument/didOpen", params);
    }

    pub fn getSource(self: Context) []const u8 {
        return self.source;
    }

    pub fn parseDoc(self: *Context) ![]const u32 {
        const params = types.SemanticTokensParams{
            .textDocument = .{ .uri = self.uri },
        };
        const rsp = try self.server.sendRequestSync(self.allocator, "textDocument/semanticTokens/full", params) orelse {
            std.debug.print("Server returned `null` as the result\n", .{});
            return error.InvalidResponse;
        };
        return rsp.data;
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
    pub fn deinit(self: *SemTokStream) void {
        _ = self;
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

const SrcLines = struct {
    off_list: std.ArrayList(usize),
    pub fn init(allocator: std.mem.Allocator) SrcLines {
        return SrcLines{ .off_list = std.ArrayList(usize).init(allocator) };
    }
    pub fn deinit(self: *SrcLines) void {
        self.off_list.deinit();
    }
    pub fn addSrc(self: *SrcLines, src: []const u8) !void {
        try self.off_list.append(0);
        var start: usize = 0;
        while (std.mem.indexOfScalarPos(u8, src, start, '\n')) |idx| {
            try self.off_list.append(idx);
            start = idx + 1;
        }
    }
    pub fn getCount(self: SrcLines) usize {
        return self.off_list.items.len - 1;
    }
    pub fn getOffset(self: SrcLines, lineno: usize) usize {
        return self.off_list.items[lineno - 1];
    }
};

pub fn exec(path: []const u8, debug: bool) ![]const u8 {
    const allocator = Heap.get();
    var ctx = try Context.init(allocator);
    // defer ctx.deinit();
    if (debug) std.log.debug("\n", .{});
    try ctx.addDoc(path);
    const toks = try ctx.parseDoc();
    var tok_str = SemTokStream.init(toks);
    // defer tok_str.deinit();
    var annotator = Annotator.init(allocator);
    // defer annotator.deinit();
    while (tok_str.next()) |tok| {
        if (debug) std.log.debug("{d},{d} {s}", .{ tok.line, tok.col, @tagName(tok.ttype) });
        const code: u8 = switch (tok.ttype) {
            .function, .method => 'f',
            .namespace, .type => 't',
            else => 0,
        };
        if (code != 0) try annotator.addItem(.{ .code = code, .line = tok.line, .pos = tok.col + tok.len });
    }
    const src = ctx.getSource();
    const res = try annotator.applyItems(src);
    return res;
}
