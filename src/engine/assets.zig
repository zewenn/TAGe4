const std = @import("std");
const zstbi = @import("zstbi");
const Allocator = @import("std").mem.Allocator;
const r = @import("./rendering/renderer.zig").r;
const v = @import("./vectors.zig");
const z = @import("./z/z.zig");

const lightmap = @import("./rendering/renderer.zig").light_levels.this();

pub const Image = zstbi.Image;

const filenames = @import("../.temp/filenames.zig").Filenames;
var files: [filenames.len][]const u8 = undefined;

var sprite_map: std.StringHashMap(r.Sprite) = undefined;
var alloc: *Allocator = undefined;

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

pub fn getPixelData(image: *const Image, pos: v.Vec2(u32)) []u8 {
    const bytes_per_pixel = image.num_components * image.bytes_per_component;
    const index = (pos.y * image.bytes_per_row) + (pos.x * bytes_per_pixel);

    return image.data[index .. index + bytes_per_pixel];
}

pub fn getPixelBrightness(comptime len: u8, _lightmap: [len]u8, op: u8) !u8 {
    var value = z.math.div(op, _lightmap.len).?;
    value = z.math.min(255, value).?;
    value = z.math.max(0, value).?;

    const uval = z.math.f128_to(u8, value);
    if (uval == null) return _lightmap[lightmap.len - 1];

    return _lightmap[uval.?];
}

pub fn init(allocator: *Allocator) !void {
    alloc = allocator;
    sprite_map = std.StringHashMap(r.Sprite).init(allocator.*);

    zstbi.init(allocator.*);

    // const testimg = try Image.loadFromMemory(files[0], 4);
    // std.debug.print("{any}", .{getPixelData(&testimg, .{ .x = 0, .y = 0 })});

    for (filenames, files) |name, data| {
        var img = try Image.loadFromMemory(data, 4);
        defer img.deinit();

        const sprite = r.Sprite.init(allocator, img.width, img.height);
        // {
        //     population = allocator.alloc([]r.Cell, img.height);
        //     for (population) |*item| {
        //         item.* = allocator.alloc(r.Cell, img.width);
        //         for (item) |*value| {
        //             value.* = r.Cell{};
        //         }
        //     }
        // }

        for (0..img.height, sprite.grid) |y, *row| {
            for (0..img.width, row.*) |x, *col| {
                const pixel_data = getPixelData(&img, .{
                    .x = @intCast(x),
                    .y = @intCast(y),
                });
                col.* = r.Cell{
                    .value = try getPixelBrightness(lightmap.len, lightmap, pixel_data[3]),
                    .foreground = .{
                        .red = pixel_data[0],
                        .green = pixel_data[1],
                        .blue = pixel_data[2],
                    },
                };
            }
        }

        try sprite_map.put(name, sprite);
    }
}

pub fn get(id: []const u8) ?r.Sprite {
    return sprite_map.get(id);
}

pub fn deinit() void {
    const kIt = sprite_map.keyIterator();

    while (@constCast(&kIt).next()) |key| {
        const val = sprite_map.get(key.*);
        if (val == null) continue;

        @constCast(&val.?).deinit();
    }

    sprite_map.deinit();
    zstbi.deinit();
}
