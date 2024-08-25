const std = @import("std");
const stbi = @import("zstbi");

pub const assets = struct {
    const filenames = @import("../.temp/filenames.zig").Filenames;
    pub var files: [filenames.len][]const u8 = undefined;

    pub inline fn compile() !void {
        var content_arr: std.ArrayListAligned([]const u8, null) = undefined;
        content_arr = std.ArrayList([]const u8).init(std.heap.page_allocator);
        defer content_arr.deinit();

        inline for (filenames) |filename| {
            try content_arr.append(@embedFile("../assets/" ++ filename));
        }

        const x2 = content_arr.toOwnedSlice() catch unreachable;
        defer std.heap.page_allocator.free(x2);

        std.mem.copyForwards([]const u8, &files, x2);
    }

    pub fn init() void {}
};
