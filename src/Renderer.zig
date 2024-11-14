const std = @import("std");
const zls = @import("zls");

const Fs = @import("Fs.zig");
const Heap = @import("Heap.zig");
const Out = @import("Out.zig");
const ZlsContext = @import("ZlsContext.zig");

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

    pub fn applyItems(self: Annotator, src: []const u8, src_lines: SrcLines) ![]const u8 {
        var last: usize = 0;
        var sb = Out.StringBuf{};
        for (self.item_list.items) |item| {
            const cur = src_lines.getOffset(item.line) + item.pos;
            const txt = src[last..cur];
            if (std.zig.isPrimitive(txt)) continue;
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
    try ZlsContext.init();
    var ctx = ZlsContext.current();
    if (debug) std.log.debug("\n", .{});
    try ctx.addDoc(path);
    const toks = try ctx.parseDoc();
    var tok_str = SemTokStream.init(toks);
    defer tok_str.deinit();
    const src = ctx.getSource();
    var src_lines = SrcLines.init(allocator);
    defer src_lines.deinit();
    try src_lines.addSrc(src);
    var annotator = Annotator.init(allocator);
    defer annotator.deinit();
    while (tok_str.next()) |tok| {
        if (debug) std.log.debug("{d},{d} {s}", .{ tok.line, tok.col, @tagName(tok.ttype) });
        var code: u8 = switch (tok.ttype) {
            .function, .method => 'f',
            .namespace, .type => 't',
            else => 0,
        };
        if (tok.ttype == .type) {
            const off = src_lines.getOffset(tok.line) + tok.col;
            if (std.zig.isPrimitive(src[off .. off + tok.len])) code = 0;
        }
        if (code != 0) try annotator.addItem(.{ .code = code, .line = tok.line, .pos = tok.col + tok.len });
    }
    // annotator.print();
    const res = try annotator.applyItems(src, src_lines);
    return res;
}
