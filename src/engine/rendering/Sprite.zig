const std = @import("std");
const v = @import("../vectors.zig");
const assert = @import("../z/z.zig").assert;

// ====================================================

const Allocator = @import("std").mem.Allocator;
const Cell = @import("./Cell.zig");
pub const Point = v.Vec2(f64);
pub const ScreenPoint = v.Vec2(i64);

// ====================================================

const Self = @This();

grid: v.HeapMatrix(Cell),
width: usize,
height: usize,
alloc: *Allocator,

pub fn init(
    allocator: *Allocator,
    width: usize,
    height: usize,
) Self {
    const _grid = allocator.alloc([]Cell, height) catch unreachable;
    for (_grid) |*row| {
        row.* = allocator.alloc(Cell, width) catch unreachable;
    }

    return Self{ .width = width, .height = height, .alloc = allocator, .grid = _grid };
}

pub fn deinit(self: *Self) void {
    for (self.grid) |*row| {
        self.alloc.free(row.*);
    }
    self.alloc.free(self.grid);
}

const PopulationError = error{SizeMismatch};

pub fn populate(self: *Self, comptime w: usize, comptime h: usize, comptime grid: v.Matrix2(Cell, w, h)) void {
    for (grid, 0..h) |row, y| {
        for (row, 0..w) |col, x| {
            self.grid[y][x] = col;
        }
    }
}

pub fn isInBounds(self: *Self, at: Point, max: Point) bool {
    var _at: *Point = @constCast(&at);
    var _at_end_x: Point = _at.add(.{
        .x = @floatFromInt(self.width),
        .y = 0,
    });
    var _at_end_y: Point = _at.add(.{
        .x = 0,
        .y = @floatFromInt(self.height),
    });
    var _at_end_xy: Point = _at.add(.{
        .x = @floatFromInt(self.width),
        .y = @floatFromInt(self.height),
    });

    const res = (_at.isInBounds(
        0,
        max.x - @as(f64, 1),
        0,
        max.y - @as(f64, 1),
    ) or
        _at_end_x.isInBounds(
        0,
        max.x - @as(f64, 1),
        0,
        max.y - @as(f64, 1),
    ) or
        _at_end_y.isInBounds(
        0,
        max.x - @as(f64, 1),
        0,
        max.y - @as(f64, 1),
    ) or
        _at_end_xy.isInBounds(
        0,
        max.x - @as(f64, 1),
        0,
        max.y - @as(f64, 1),
    ));

    // std.debug.print("{?} - {?} => {s}\n", .{ _at, _at_end_x, if (res) "true" else "false" });

    return res;
}
