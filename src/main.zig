const std = @import("std");

const cli = @import("zig-cli");

const Fs = @import("./Fs.zig");
const Heap = @import("./Heap.zig");
const Props = @import("./Props.zig");
const Session = @import("./Session.zig");

var t0: f80 = 0.0;

var params = struct {
    load: bool = false,
    meta: bool = false,
    setup: ?[]const u8 = null,
    unit: []const u8 = undefined,
    work: []const u8 = ".",
}{};

fn doBuild() !void {
    const writer = std.io.getStdOut().writer();
    const path = params.unit;
    const idx = std.mem.indexOf(u8, path, "/").?;
    const bn = path[0..idx];
    const un = path[idx + 1 ..];
    try Session.activate(.{ .work = params.work, .mode = .BUILD, .bundle = bn, .setup = params.setup });
    try Session.doRefresh();
    try Session.doBuild(un);
    try writer.print("compiling HOST ...\n", .{});
    var stdout = try execMake("host");
    if (stdout.len > 0) std.log.debug("stdout = {s}", .{stdout});
    if (params.meta) {
        const t2: f80 = @floatFromInt(std.time.milliTimestamp());
        try writer.print("done in {d:.2} seconds\n", .{(t2 - t0) / 1000.0});
        return;
    }
    try writer.print("compiling TARG ...\n", .{});
    stdout = try execMake("TARG");
    const sha32 = Fs.readFile(Fs.join(&.{ Session.getOutRoot(), "main.out.sha32" }));
    try writer.print("    image sha: {s}", .{sha32}); // contains \n
    const sz = try getSizes(stdout);
    try writer.print("    image size: text ({d}) + const ({d}) + data ({d}) + bss ({d})\n", .{ sz[0], sz[1], sz[2], sz[3] });
    const t2: f80 = @floatFromInt(std.time.milliTimestamp());
    try writer.print("done in {d:.2} seconds\n", .{(t2 - t0) / 1000.0});
    if (!params.load) return;
    try writer.print("loading...\n", .{});
    stdout = try execMake("load");
    // if (stdout.len > 0) std.log.debug("stdout = {s}", .{stdout});
    try writer.print("done.\n", .{});
}

fn doClean() !void {
    try Session.activate(.{ .work = params.work, .mode = .CLEAN });
}

fn doProperties() !void {
    try Session.activate(.{ .work = params.work, .mode = .REFRESH, .setup = params.setup });
    const writer = std.io.getStdOut().writer();
    const pm = Props.getProps();
    var ent_iter = pm.iterator();
    while (ent_iter.next()) |e| try writer.print("{s} = {s}\n", .{ e.key_ptr.*, e.value_ptr.* });
}

fn doRefresh() !void {
    try Session.activate(.{ .work = params.work, .mode = .REFRESH });
    try Session.doRefresh();
}

fn execMake(goal: []const u8) ![]const u8 {
    const argv = [_][]const u8{ "make", goal };
    const proc = try std.process.Child.run(.{
        .allocator = Heap.get(),
        .argv = &argv,
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

pub fn main() !void {
    defer Heap.deinit();
    t0 = @floatFromInt(std.time.milliTimestamp());
    var runner = try cli.AppRunner.init(Heap.get());

    const load_opt = cli.Option{
        .long_name = "load",
        .short_alias = 'l',
        .help = "Load executable image after building",
        .required = false,
        .value_name = "LOAD",
        .value_ref = runner.mkRef(&params.load),
    };

    const meta_opt = cli.Option{
        .long_name = "meta-only",
        .short_alias = 'm',
        .help = "Only run the HOST meta-program",
        .required = false,
        .value_name = "META",
        .value_ref = runner.mkRef(&params.meta),
    };

    const setup_opt = cli.Option{
        .long_name = "setup",
        .short_alias = 's',
        .help = "Setup name",
        .required = false,
        .value_name = "SETUP",
        .value_ref = runner.mkRef(&params.setup),
    };

    const unit_opt = cli.Option{
        .long_name = "unit",
        .short_alias = 'u',
        .help = "Workspace-relative path to <unit>.em.zig file",
        .required = true,
        .value_name = "UPATH",
        .value_ref = runner.mkRef(&params.unit),
    };

    const work_opt = cli.Option{
        .long_name = "workspace",
        .short_alias = 'w',
        .help = "Root location of the workspace",
        .required = false,
        .value_name = "WPATH",
        .value_ref = runner.mkRef(&params.work),
    };

    const build_cmd = cli.Command{
        .name = "build",
        .options = &.{
            load_opt,
            meta_opt,
            setup_opt,
            unit_opt,
            work_opt,
        },
        .target = cli.CommandTarget{
            .action = cli.CommandAction{ .exec = doBuild },
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

    const refresh_cmd = cli.Command{
        .name = "refresh",
        .options = &.{
            work_opt,
        },
        .target = cli.CommandTarget{
            .action = cli.CommandAction{ .exec = doRefresh },
        },
    };

    const app = &cli.App{
        .command = cli.Command{
            .name = "zig-em",
            .target = cli.CommandTarget{
                .subcommands = &.{
                    build_cmd,
                    clean_cmd,
                    properties_cmd,
                    refresh_cmd,
                },
            },
        },
        .help_config = cli.HelpConfig{ .color_usage = .never },
        .version = "0.24.0",
    };

    return runner.run(app);
}
