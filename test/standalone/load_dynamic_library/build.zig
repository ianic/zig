const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const test_step = b.step("test", "Test it");
    b.default_step = test_step;

    const optimize: std.builtin.OptimizeMode = .Debug;
    const target = b.graph.host;

    if (builtin.os.tag == .wasi) return;

    const lib = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "add",
        .version = .{ .major = 1, .minor = 0, .patch = 0 },
        .root_module = b.createModule(.{
            .root_source_file = b.path("add.zig"),
            .optimize = optimize,
            .target = target,
        }),
    });

    const main = b.addExecutable(.{
        .name = "main",
        .root_module = b.createModule(.{
            .root_source_file = b.path("main.zig"),
            .optimize = optimize,
            .target = target,
        }),
    });

    const run = b.addRunArtifact(main);
    run.addArtifactArg(lib);
    run.skip_foreign_checks = true;
    run.expectExitCode(0);

    test_step.dependOn(&run.step);
}
