const std = @import("std");
const builtin = @import("builtin");

const cli = @import("zig-cli");

const Fs = @import("./Fs.zig");
const Heap = @import("./Heap.zig");
const Markdown = @import("Markdown.zig");
const Parser = @import("Parser.zig");
const Props = @import("./Props.zig");
const Publisher = @import("./Publisher.zig");
const Renderer = @import("./Renderer.zig");
const Session = @import("./Session.zig");

var writer: @TypeOf(std.io.getStdOut().writer()) = undefined;

var t0: f80 = 0.0;

var params = struct {
    delay: u32 = 0,
    dry: bool = false,
    force: bool = false,
    load: bool = false,
    meta: bool = false,
    out: []const u8 = ".",
    pkg: []const u8 = "em.core",
    setup: ?[]const u8 = null,
    unit: []const u8 = undefined,
    verbose: bool = false,
    work: []const u8 = ".",
}{};

var results = struct {
    program: []const u8 = "",
    board: []const u8 = "",
    setup: []const u8 = "",
    sha: []const u8 = "",
    textSize: usize = 0,
    constSize: usize = 0,
    dataSize: usize = 0,
    bssSize: usize = 0,
    secondsToBuild: f80 = 0.0,
    secondsToLoad: f80 = 0.0,
    secondsTotal: f80 = 0.0,
    load: bool = false,
}{};

fn doCheck() !void {
    const path = params.unit;
    const idx = std.mem.indexOf(u8, path, "/").?;
    const un = path[idx + 1 ..];
    try Session.activate(.{ .work = params.work, .mode = .CHECK });
    try Session.doCheck(un);
    const stdout = try execMake("check");
    if (stdout.len > 0) std.log.debug("stdout = {s}", .{stdout});
    try printDone();
}

fn doClean() !void {
    try Session.activate(.{ .work = params.work, .mode = .CLEAN });
}

fn doCompile() !void {
    const path = params.unit;
    const idx = std.mem.indexOf(u8, path, "/").?;
    const bn = path[0..idx];
    const un = path[idx + 1 ..];
    try Session.activate(.{ .work = params.work, .mode = .COMPILE, .bundle = bn, .setup = params.setup });
    try Session.doRefresh();
    try Session.doBuild(un);
    // try writer.print("compiling META ...\n", .{});
    // try writer.print("    board: {s}\n", .{Session.getBoard()});
    // try writer.print("    setup: {s}\n", .{Session.getSetup()});
    var stdout = try execMake("meta");
    if (stdout.len > 0) std.log.debug("stdout = {s}", .{stdout});
    if (params.meta) {
        // try printDone();
        return;
    }
    // try writer.print("compiling TARG ...\n", .{});
    stdout = try execMake("targ");
    const sha32 = Fs.readFile(Fs.join(&.{ Session.getOutRoot(), "main.out.sha32" }));
    // try writer.print("    image sha: {s}", .{sha32}); // contains \n
    const sz = try getSizes(stdout);
    // try writer.print("    image size: text ({d}) + const ({d}) + data ({d}) + bss ({d})\n", .{ sz[0], sz[1], sz[2], sz[3] });
    // try printDone();
    const t2: f80 = @floatFromInt(std.time.milliTimestamp());
    if (params.load) {
        // try writer.print("loading...\n", .{});
        stdout = try execMake("load");
        // if (stdout.len > 0) std.log.debug("stdout = {s}", .{stdout});
        // try writer.print("done.\n", .{});
    }
    const t3: f80 = @floatFromInt(std.time.milliTimestamp());
    results.program = params.unit;
    results.board = Session.getBoard();
    results.setup = Session.getSetup();
    results.sha = sha32[0 .. sha32.len - 1]; // strip new line
    results.textSize = sz[0];
    results.constSize = sz[1];
    results.dataSize = sz[2];
    results.bssSize = sz[3];
    results.secondsToBuild = (t2 - t0) / 1000.0;
    results.secondsToLoad = if (params.load) (t3 - t2) / 1000.0 else 0.0;
    results.secondsTotal = results.secondsToBuild + results.secondsToLoad;
    results.load = params.load;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const resultsJson = try std.json.stringifyAlloc(allocator, results, .{ .whitespace = .indent_2 });
    defer allocator.free(resultsJson);
    try writer.print("{s}\n", .{resultsJson});
}

fn doMarkdown() !void {
    const wpath = try Fs.normalize(params.work);
    const ppath = Fs.slashify(Fs.join(&.{ wpath, params.pkg }));
    const opath = try Fs.normalize(params.out);
    try Markdown.generate(ppath, opath, params.delay, params.dry);
}

fn doParse() !void {
    try Parser.exec(params.unit);
}

fn doProperties() !void {
    try Session.activate(.{ .work = params.work, .mode = .REFRESH, .setup = params.setup });
    const pm = Props.getProps();
    var ent_iter = pm.iterator();
    while (ent_iter.next()) |e| try writer.print("{s} = {s}\n", .{ e.key_ptr.*, e.value_ptr.* });
}

fn doPublish() !void {
    if (params.force) try writer.print("{s}\n", .{params.unit});
    try Publisher.exec(params.unit, params.force);
    if (!params.force) try printDone();
}

fn doRefresh() !void {
    try Session.activate(.{ .work = params.work, .mode = .REFRESH });
    try Session.doRefresh();
    try printDone();
}

fn doRender() !void {
    const src = try Renderer.exec(params.unit, params.verbose);
    _ = try writer.write(src);
}

fn execMake(goal: []const u8) ![]const u8 {
    const OS = "OS=" ++ @tagName(builtin.os.tag);
    const argv = [_][]const u8{ "make", "-f", "zigem/makefile", goal, OS };
    const proc = try std.process.Child.run(.{
        .allocator = Heap.get(),
        .argv = &argv,
        // .cwd = Fs.join(&.{ Fs.cwd(), "build" }),
    });

    if (proc.stderr.len > 0) {
        try std.io.getStdErr().writeAll(proc.stderr);
    }
    if (proc.term.Exited != 0) {
        std.log.err("make {s} failed", .{goal});
        std.process.exit(1);
    }
    return proc.stdout;
}

fn getSizes(lines: []const u8) ![4]usize {
    var textSz: usize = 0;
    var constSz: usize = 0;
    var dataSz: usize = 0;
    var bssSz: usize = 0;
    var it = std.mem.splitSequence(u8, lines, "\n");
    _ = it.first();
    while (it.next()) |ln| {
        if (!std.mem.startsWith(u8, ln, " ")) continue;
        const idx = std.mem.indexOf(u8, ln, ".");
        if (idx == null) continue;
        const ln2 = ln[idx.? + 1 ..];
        var it2 = std.mem.tokenizeScalar(u8, ln2, ' ');
        const s1 = it2.next().?;
        const s2 = it2.next().?;
        const sz = try std.fmt.parseInt(u32, s2, 16);
        if (std.mem.eql(u8, s1, "text")) textSz += sz;
        if (std.mem.eql(u8, s1, "const")) constSz += sz;
        if (std.mem.eql(u8, s1, "data")) dataSz += sz;
        if (std.mem.eql(u8, s1, "bss")) bssSz += sz;
    }
    return .{ textSz, constSz, dataSz, bssSz };
}

fn printDone() !void {
    const t2: f80 = @floatFromInt(std.time.milliTimestamp());
    try writer.print("done in {d:.2} seconds\n", .{(t2 - t0) / 1000.0});
}

pub fn main() !void {
    defer Heap.deinit();
    writer = std.io.getStdOut().writer();
    t0 = @floatFromInt(std.time.milliTimestamp());
    var runner = try cli.AppRunner.init(Heap.get());

    const delay_opt = cli.Option{
        .long_name = "delay",
        .help = "Delay count",
        .required = false,
        .value_name = "DELAY",
        .value_ref = runner.mkRef(&params.delay),
    };

    const dry_opt = cli.Option{
        .long_name = "dry-run",
        .help = "Dry run - no output",
        .required = false,
        .value_name = "DRY",
        .value_ref = runner.mkRef(&params.dry),
    };

    const file_req = cli.Option{
        .long_name = "file",
        .short_alias = 'f',
        .help = "Workspace-relative path to a <unit>.em.zig source file",
        .required = true,
        .value_name = "UPATH",
        .value_ref = runner.mkRef(&params.unit),
    };

    const force_opt = cli.Option{
        .long_name = "force",
        .help = "Force this operation",
        .required = false,
        .value_name = "FORCE",
        .value_ref = runner.mkRef(&params.force),
    };

    const load_opt = cli.Option{
        .long_name = "load",
        .short_alias = 'l',
        .help = "Load executable image after compiling",
        .required = false,
        .value_name = "LOAD",
        .value_ref = runner.mkRef(&params.load),
    };

    const meta_opt = cli.Option{
        .long_name = "meta",
        .short_alias = 'm',
        .help = "Only run the hosted meta-program",
        .required = false,
        .value_name = "META",
        .value_ref = runner.mkRef(&params.meta),
    };

    const out_opt = cli.Option{
        .long_name = "output",
        .short_alias = 'o',
        .help = "Output path",
        .required = false,
        .value_name = "OPATH",
        .value_ref = runner.mkRef(&params.out),
    };

    const pkg_opt = cli.Option{
        .long_name = "package",
        .short_alias = 'p',
        .help = "Package name",
        .required = false,
        .value_name = "PNAME",
        .value_ref = runner.mkRef(&params.pkg),
    };

    const setup_opt = cli.Option{
        .long_name = "setup",
        .short_alias = 's',
        .help = "Setup name",
        .required = false,
        .value_name = "SETUP",
        .value_ref = runner.mkRef(&params.setup),
    };

    const verbose_opt = cli.Option{
        .long_name = "verbose",
        .help = "Verbose output",
        .required = false,
        .value_name = "VERBOSE",
        .value_ref = runner.mkRef(&params.verbose),
    };

    const work_opt = cli.Option{
        .long_name = "workspace",
        .short_alias = 'w',
        .help = "Root location of the workspace",
        .required = false,
        .value_name = "WPATH",
        .value_ref = runner.mkRef(&params.work),
    };

    const check_cmd = cli.Command{
        .name = "check",
        .description = cli.Description{ .one_line = "semantic checking" },
        .options = &.{
            file_req,
            work_opt,
        },
        .target = cli.CommandTarget{
            .action = cli.CommandAction{ .exec = doCheck },
        },
    };

    const clean_cmd = cli.Command{
        .name = "clean",
        .options = &.{
            work_opt,
        },
        .target = cli.CommandTarget{
            .action = cli.CommandAction{ .exec = doClean },
        },
    };

    const compile_cmd = cli.Command{
        .name = "compile",
        .options = &.{
            file_req,
            load_opt,
            meta_opt,
            setup_opt,
            work_opt,
        },
        .target = cli.CommandTarget{
            .action = cli.CommandAction{ .exec = doCompile },
        },
    };

    const markdown_cmd = cli.Command{
        .name = "markdown",
        .description = cli.Description{ .one_line = "*** WIP ***" },
        .options = &.{
            delay_opt,
            dry_opt,
            out_opt,
            pkg_opt,
            work_opt,
        },
        .target = cli.CommandTarget{
            .action = cli.CommandAction{ .exec = doMarkdown },
        },
    };

    const parse_cmd = cli.Command{
        .name = "parse",
        .description = cli.Description{ .one_line = "*** WIP ***" },
        .options = &.{
            file_req,
            work_opt,
        },
        .target = cli.CommandTarget{
            .action = cli.CommandAction{ .exec = doParse },
        },
    };

    const properties_cmd = cli.Command{
        .name = "properties",
        .options = &.{
            setup_opt,
            work_opt,
        },
        .target = cli.CommandTarget{
            .action = cli.CommandAction{ .exec = doProperties },
        },
    };

    const publish_cmd = cli.Command{
        .name = "publish",
        .description = cli.Description{ .one_line = "*** WIP ***" },
        .options = &.{
            file_req,
            force_opt,
            work_opt,
        },
        .target = cli.CommandTarget{
            .action = cli.CommandAction{ .exec = doPublish },
        },
    };

    const refresh_cmd = cli.Command{
        .name = "refresh",
        .options = &.{
            work_opt,
        },
        .target = cli.CommandTarget{
            .action = cli.CommandAction{ .exec = doRefresh },
        },
    };

    const render_cmd = cli.Command{
        .name = "render",
        .description = cli.Description{ .one_line = "*** WIP ***" },
        .options = &.{
            file_req,
            verbose_opt,
            work_opt,
        },
        .target = cli.CommandTarget{
            .action = cli.CommandAction{ .exec = doRender },
        },
    };

    const app = &cli.App{
        .command = cli.Command{
            .name = "zigem",
            .target = cli.CommandTarget{
                .subcommands = &.{
                    check_cmd,
                    clean_cmd,
                    compile_cmd,
                    markdown_cmd,
                    parse_cmd,
                    properties_cmd,
                    publish_cmd,
                    refresh_cmd,
                    render_cmd,
                },
            },
        },
        .help_config = cli.HelpConfig{ .color_usage = .never },
        .author = "The EM Foundation",
        .version = "25.0.1",
    };

    return runner.run(app);
}

pub const std_options = .{
    .logFn = log,
};

pub fn log(
    comptime message_level: std.log.Level,
    comptime scope: @Type(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    if (message_level != .err) {
        if (message_level == .debug and std.mem.startsWith(u8, format, "***")) return;
        if (std.mem.startsWith(u8, @tagName(scope), "zls_config")) return;
        if (std.mem.startsWith(u8, @tagName(scope), "zls_server")) return;
        if (std.mem.startsWith(u8, @tagName(scope), "zls_store")) return;
    }
    std.log.defaultLog(message_level, scope, format, args);
}
