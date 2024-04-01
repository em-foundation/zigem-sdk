const std = @import("std");

const cli = @import("zig-cli");
const heap = @import("./heap.zig");
const zgf = @import("zon_get_fields");

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
    .help = "Specify the unit path",
    .required = true,
    .value_name = "UPATH",
    .value_ref = cli.mkRef(&params.unit),
};

var build_cmd = cli.Command{
    .name = "build",
    .options = &.{
        &bundle_opt,
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
    std.log.debug("build: bundle = {s}, unit = {s}", .{ params.bundle, params.unit });
}

fn doClean() !void {
    std.log.debug("clean: bundle = {s}", .{params.bundle});
}

pub fn main() !void {
    defer heap.deinit();
    return cli.run(app, heap.get());
}
