const std = @import("std");
const stbi = @import("zstbi");

pub const assets = struct {
    pub const filenames = [_][]const u8{ "rainbow.png", "player_left_0.png" };
    pub var files: [filenames.len][]const u8 = undefined;

    pub inline fn init() !void {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        defer _ = gpa.deinit();

        const allocator = gpa.allocator();

        var content_arr: std.ArrayListAligned([]const u8, null) = undefined;
        content_arr = std.ArrayList([]const u8).init(allocator);
        defer content_arr.deinit();

        inline for (filenames) |filename| {
            try content_arr.append(@embedFile("../assets/" ++ filename));
        }

        const x2 = content_arr.toOwnedSlice() catch unreachable;
        defer allocator.free(x2);

        std.mem.copyForwards([]const u8, &files, x2);
    }
};
