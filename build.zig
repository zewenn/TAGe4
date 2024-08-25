const std = @import("std");
const Allocator = @import("std").mem.Allocator;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "tag4",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Image processing and sprite loading
    const zstbi = b.dependency("zstbi", .{});
    {
        exe.root_module.addImport("zstbi", zstbi.module("root"));
        exe.linkLibrary(zstbi.artifact("zstbi"));
    }

    // Linking platrofm specific frameworks
    switch (@import("builtin").os.tag) {
        .macos => {
            exe.linkFramework("ApplicationServices");
            exe.linkFramework("IOKit");
            exe.linkFramework("CoreFoundation");
            exe.linkSystemLibrary("ncurses");
        },
        else => {},
    }

    // Well, you always need libC
    exe.linkLibC();

    // Automatic file "import"
    {
        const files_dir = "./src/assets/";
        const output_file = std.fs.cwd().createFile("src/.temp/filenames.zig", .{}) catch unreachable;

        const seg = generateFileNames(files_dir);
        defer {
            seg.list.deinit();
        }

        var writer = output_file.writer();
        _ = writer.write("pub const Filenames = [_][]const u8{\n") catch unreachable;
        for (seg.list.items, 0..seg.list.items.len) |item, i| {
            if (i == 0) {
                _ = writer.write("\t\"") catch unreachable;
            } else {
                _ = writer.write("\",\n\t\"") catch unreachable;
            }
            writer.print("{s}", .{item}) catch unreachable;
            if (i == seg.list.items.len - 1) {
                _ = writer.write("\"") catch unreachable;
            }
        }
        _ = writer.write("\n};") catch unreachable;
    }

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}

const Segment = struct {
    alloc: std.mem.Allocator,
    list: std.ArrayListAligned([]const u8, null),
};

fn generateFileNames(files_dir: []const u8) Segment {
    const dir = std.fs.cwd().openDir(files_dir, .{ .iterate = true }) catch unreachable;
    defer @constCast(&dir).close();
    
    var result = std.ArrayList([]const u8).init(std.heap.page_allocator);
    // defer result.deinit();

    var it = dir.iterate();
    while (it.next() catch unreachable) |entry| {
        if (entry.kind == .file) {
            result.append(entry.name) catch unreachable;
        }
    }

    return Segment{
        .alloc = std.heap.page_allocator,
        .list = result,
    };
}
