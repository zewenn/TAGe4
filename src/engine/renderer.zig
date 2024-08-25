const std = @import("std");
const v = @import("./vectors.zig");
const assert = @import("./z.zig").assert;
const Allocator = @import("std").mem.Allocator;
pub const Point = v.Vec2(f64);
pub const ScreenPoint = v.Vec2(i64);

pub const Colour = struct {
    const Self = @This();
    red: u8,
    green: u8,
    blue: u8,

    pub fn eql(col1: *Self, col2: Self) bool {
        if (col1.red != col2.red) return false;
        if (col1.green != col2.green) return false;
        if (col1.blue != col2.blue) return false;

        return true;
    }
};

pub const Cell = struct {
    const Self = @This();
    value: u8 = ' ',
    foreground: Colour = Colour{ .red = 255, .green = 255, .blue = 255 },
    background: Colour = Colour{ .red = 0, .green = 0, .blue = 0 },

    pub fn eql(cell1: *Self, cell2: Self) bool {
        if (cell1.value != cell2.value) return false;
        if (!cell1.foreground.eql(cell2.foreground)) return false;
        if (!cell1.background.eql(cell2.background)) return false;

        return true;
    }
};

pub const Sprite = struct {
    const Self = @This();

    grid: v.HeapMatrix(Cell),
    width: usize,
    height: usize,
    alloc: *Allocator,

    pub fn init(
        allocator: *Allocator,
        comptime width: usize,
        comptime height: usize,
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
};

// pub const ScreenBuffer: type = [30][120]u8;
const DisplayOptions = struct {
    size: v.Vec2(u16) = v.Vec2(u16).init(120, 30),
};

pub inline fn Display(comptime options: DisplayOptions) type {
    const CellBuffer: type = v.Matrix2(Cell, options.size.x, options.size.y);

    return struct {
        var original_buffer: CellBuffer = [_][120]Cell{[_]Cell{Cell{}} ** 120} ** 30;
        // var buf1: ScreenBuffer = [_][120]u8{[_]u8{' '} ** 120} ** 30;
        var buf1: CellBuffer = undefined;
        var buf2: CellBuffer = undefined;

        var stdOut: std.fs.File = undefined;
        var writer: std.fs.File.Writer = undefined;

        pub fn print(comptime bytes: []const u8, args: anytype) void {
            writer.print(bytes, args) catch return;
        }

        pub fn init() void {
            clearScreen();

            Cursor.hide();
            stdOut = std.io.getStdOut();
            writer = stdOut.writer();

            @memcpy(&buf1, &original_buffer);
            @memcpy(&buf2, &original_buffer);

            for (0..buf1.len) |y| {
                for (0..buf1[0].len) |x| {
                    print("\x1b[38;2;{d};{d};{d}m\x1b[48;2;{d};{d};{d}m{c}\x1b[0m", .{
                        buf1[y][x].foreground.red,
                        buf1[y][x].foreground.green,
                        buf1[y][x].foreground.blue,
                        //
                        buf1[y][x].background.red,
                        buf1[y][x].background.green,
                        buf1[y][x].background.blue,
                        //
                        buf1[y][x].value,
                    });
                }
                print("\n", .{});
            }
        }

        pub fn deinit() void {
            Cursor.show();
            clearScreen();
        }

        pub fn clearScreen() void {
            print("\x1b[2J\x1b[H", .{});
        }

        fn isOnScreen(x: i64, y: i64) bool {
            if ((x < 0 or y < 0) or (x >= options.size.x or y >= options.size.y)) {
                return false;
            }
            return true;
        }

        pub fn clearBuffer() void {
            @memcpy(&buf2, &original_buffer);
        }

        pub const Cursor = struct {
            pub fn hide() void {
                std.debug.print("\x1b[?25l", .{});
            }
            pub fn show() void {
                std.debug.print("\x1b[?25h", .{});
            }
            pub fn move(x: u8, y: u8) void {
                var _x = x;
                var _y = y;

                if (_x >= options.size.x) _x = @intCast(options.size.x - 1);
                if (_y >= options.size.y) _y = @intCast(options.size.y - 1);

                print("\x1b[{d};{d}H", .{ _y + 1, _x + 1 });
            }
        };

        pub fn blitString(at: Point, content: []const u8) void {
            var _at: ScreenPoint = ScreenPoint.init(
                @intFromFloat(at.x),
                @intFromFloat(at.y),
            );

            if (!_at.isInBounds(0, options.size.x - 1, 0, options.size.y - 1)) {
                return;
            }

            const start_x: usize = @intCast(_at.x);
            const start_y: usize = @intCast(_at.y);

            for (0..content.len) |x| {
                if (!isOnScreen(@intCast(start_x + x), @intCast(start_y))) continue;
                buf2[start_y][start_x + x].value = content[x];
            }
        }

        pub fn blit(at: Point, sprite: Sprite) void {
            var _sprite: *Sprite = undefined;
            _sprite = @constCast(&sprite);

            const _at = ScreenPoint.init(
                @intFromFloat(at.x),
                @intFromFloat(at.y),
            );

            if (!_sprite.isInBounds(at, Point{
                .x = @floatFromInt(options.size.x),
                .y = @floatFromInt(options.size.y),
            })) {
                return;
            }

            const start_x = _at.x;
            const start_y = _at.y;

            for (0.._sprite.grid.len) |dh| {
                for (0.._sprite.grid[0].len) |dw| {
                    const px: i64 = start_x + @as(i64, @intCast(dw));
                    const py: i64 = start_y + @as(i64, @intCast(dh));

                    if (!isOnScreen(px, py)) continue;

                    const x: usize = @intCast(px);
                    const y: usize = @intCast(py);

                    buf2[y][x] = _sprite.grid[dh][dw];
                }
            }
        }

        pub fn apply() void {
            assert(buf1.len == buf2.len, "the buffers have mismatched sizes");

            for (0..buf1.len) |y| {
                for (0..buf1[0].len) |x| {
                    if (!buf1[y][x].eql(buf2[y][x])) {
                        buf1[y][x] = buf2[y][x];
                        Cursor.move(@intCast(x), @intCast(y));
                        print("\x1b[38;2;{d};{d};{d}m\x1b[48;2;{d};{d};{d}m{c}\x1b[0m", .{
                            buf1[y][x].foreground.red,
                            buf1[y][x].foreground.green,
                            buf1[y][x].foreground.blue,
                            //
                            buf1[y][x].background.red,
                            buf1[y][x].background.green,
                            buf1[y][x].background.blue,
                            //
                            buf1[y][x].value,
                        });
                    }
                }
            }
        }
    };
}
