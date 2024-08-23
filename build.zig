const std = @import("std");

pub fn build(b: *std.Build) void {
    //
    const target = b.host;
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

    const tr = target.result;
    for (TOOLS) |name| {
        const dep = b.dependency(b.fmt("{s}-{s}-{s}", .{ name, @tagName(tr.os.tag), tr.osArchName() }), .{});
        const install_step = b.addInstallDirectory(.{
            .source_dir = dep.path("."),
            .install_dir = std.Build.InstallDir{ .custom = "tools" },
            .install_subdir = name,
        });
        exe.step.dependOn(&install_step.step);
    }

    b.installArtifact(exe);

    const verify_exe = b.addRunArtifact(exe);
    verify_exe.setCwd(std.Build.LazyPath{ .src_path = .{ .owner = b, .sub_path = "work" } });
    verify_exe.addArgs(&.{ "build", "-u", "em.test/em.examples.basic/BlinkerP.em.zig" });
    const verify_step = b.step("verify", "Verify zig-em");
    verify_step.dependOn(&verify_exe.step);

    const zigem_exe = b.addRunArtifact(exe);
    if (b.args) |args| zigem_exe.addArgs(args);
    zigem_exe.setCwd(std.Build.LazyPath{ .src_path = .{ .owner = b, .sub_path = "work" } });
    const zigem_step = b.step("zig-em", "Execute the ZigEM CLI");
    zigem_step.dependOn(&zigem_exe.step);
}

const DEPS = [_][]const u8{
    "ini",
    "zig-cli",
};

const TOOLS = [_][]const u8{
    "arm-binutils",
    "ti-uniflash",
};
