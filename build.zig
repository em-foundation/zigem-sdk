const std = @import("std");

const DEPS = [_][]const u8{
    "ini",
    "zig-cli",
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "zig-em",
        .root_source_file = std.Build.path(b, "src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    for (DEPS) |name| {
        const dep = b.dependency(name, .{
            .target = target,
            .optimize = optimize,
        });
        exe.root_module.addImport(name, dep.module(name));
    }

    b.installArtifact(exe);
}
