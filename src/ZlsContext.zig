const std = @import("std");

const builtin = @import("builtin");
const zls = @import("zls");

const Fs = @import("Fs.zig");
const Heap = @import("Heap.zig");

var cur_ctx: Context = undefined;
var init_flg = false;

pub fn current() Context {
    return cur_ctx;
}

pub fn init() !void {
    init_flg = true;
    cur_ctx = try Context.init(Heap.get());
}

const types = zls.types;

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
        if (std.mem.indexOf(u8, self.source, "//")) |idx| {
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
