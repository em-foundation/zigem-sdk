const std = @import("std");

const cli = @import("zig-cli");

const Heap = @import("./Heap.zig");
const Session = @import("./Session.zig");

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

fn doBuild() !void {
    const path = params.unit;
    const idx = std.mem.indexOf(u8, path, "/").?;
    const bn = path[0..idx];
    const un = path[idx + 1 ..];
    try Session.activate(bn, .BUILD, null);
    try Session.generate(un);
}

fn doClean() !void {
    try Session.activate(params.bundle, .CLEAN, null);
}

pub fn main() !void {
    defer Heap.deinit();
    return cli.run(app, Heap.get());
}
