const std = @import("std");

const cli = @import("zig-cli");

const Heap = @import("./Heap.zig");
const Session = @import("./Session.zig");

var t0: f80 = 0.0;

var params = struct {
    bundle: []const u8 = ".",
    unit: []const u8 = undefined,
}{};

var bundle_opt = cli.Option{
    .long_name = "bundle",
    .short_alias = 'b',
    .help = "Specify the working bundle",
    .required = false,
    .value_name = "BPATH",
    .value_ref = cli.mkRef(&params.bundle),
};

var unit_opt = cli.Option{
    .long_name = "unit",
    .short_alias = 'u',
    .help = "Workspace-relative path to <unit>.em.zig file",
    .required = true,
    .value_name = "UPATH",
    .value_ref = cli.mkRef(&params.unit),
};

var build_cmd = cli.Command{
    .name = "build",
    .options = &.{
        &unit_opt,
    },
    .target = cli.CommandTarget{
        .action = cli.CommandAction{ .exec = doBuild },
    },
};

var clean_cmd = cli.Command{
    .name = "clean",
    .options = &.{
        &bundle_opt,
    },
    .target = cli.CommandTarget{
        .action = cli.CommandAction{ .exec = doClean },
    },
};

const app = &cli.App{
    .command = cli.Command{
        .name = "zig-em",
        .target = cli.CommandTarget{
            .subcommands = &.{
                &build_cmd,
                &clean_cmd,
            },
        },
    },
    .help_config = cli.HelpConfig{ .color_usage = .never },
    .version = "0.24.0",
};

fn dispSizes(lines: []const u8) ![4]usize {
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

fn doBuild() !void {
    const writer = std.io.getStdOut().writer();
    const path = params.unit;
    const idx = std.mem.indexOf(u8, path, "/").?;
    const bn = path[0..idx];
    const un = path[idx + 1 ..];
    try Session.activate(bn, .BUILD, null);
    try Session.generate(un);
    try writer.print("compiling HOST ...\n", .{});
    var stdout = try execMake("host");
    if (stdout.len > 0) std.log.debug("stdout = {s}", .{stdout});
    try writer.print("compiling TARG ...\n", .{});
    stdout = try execMake("TARG");
    const sz = try dispSizes(stdout);
    try writer.print("    image size: text ({d}) + const ({d}) + data ({d}) + bss ({d})\n", .{ sz[0], sz[1], sz[2], sz[3] });
    const t2: f80 = @floatFromInt(std.time.milliTimestamp());
    try writer.print("done in {d:.2} seconds\n", .{(t2 - t0) / 1000.0});
}

fn doClean() !void {
    try Session.activate(params.bundle, .CLEAN, null);
}

fn execMake(goal: []const u8) ![]const u8 {
    const argv = [_][]const u8{ "make", goal };
    const proc = try std.ChildProcess.run(.{
        .allocator = Heap.get(),
        .argv = &argv,
    });

    if (proc.term.Exited != 0) {
        std.log.err("make {s} failed: {s}", .{ goal, proc.stderr });
        std.process.exit(1);
    }
    return proc.stdout;
}

pub fn main() !void {
    defer Heap.deinit();
    t0 = @floatFromInt(std.time.milliTimestamp());
    return cli.run(app, Heap.get());
}
