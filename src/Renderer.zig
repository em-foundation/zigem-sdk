const std = @import("std");
const zls = @import("zls");

const Ast = std.zig.Ast;
const Fs = @import("Fs.zig");
const Heap = @import("Heap.zig");

pub fn exec(path: []const u8) !void {
    var ctx = try Context.init();
    defer ctx.deinit();

    std.log.debug("\n\n", .{});
    const txt = Fs.readFileZ(try Fs.normalize(path));

    const uri = try ctx.addDocument(txt);
    std.log.debug("uri = {s}", .{uri});

    // const ast = try Ast.parse(Heap.get(), txt, .zig);
    // std.log.debug("root: {any}", .{ast.rootDecls()});
    // std.log.debug("var: {any}", .{ast.simpleVarDecl(1)});
    // std.log.debug("id: {any}", .{ast.tokens.get(3)});
    // for (0..ast.nodes.len) |i| {
    //     std.log.debug("node{d}: {any}", .{ i, ast.nodes.get(i) });
    // }
    // const rend = try ast.render(Heap.get());
    // std.log.debug("{s}", .{rend});
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

pub const Context = struct {
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
    pub fn addDocument(self: *Context, source: []const u8) ![]const u8 {
        const fmt = switch (builtin.os.tag) {
            .windows => "file:///C:\\nonexistent\\test-{d}.zig",
            else => "file:///nonexistent/test-{d}.zig",
        };
        const uri = try std.fmt.allocPrint(
            Heap.get(),
            fmt,
            .{0},
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
