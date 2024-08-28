const std = @import("std");
const v = @import("../vectors.zig");
const assert = @import("../z/z.zig").assert;
const z = @import("../z/z.zig");

// ====================================================

const Allocator = @import("std").mem.Allocator;
const Cell = @import("./Cell.zig");
const Sprite = @import("./Sprite.zig");
pub const Point = v.Vec2(f64);
pub const ScreenPoint = v.Vec2(i64);

// ====================================================

pub const r = struct {
    pub const Cell: type = @import("Cell.zig");
    pub const Sprite: type = @import("Sprite.zig");
};

pub const light_levels = z.arrays.Array(u8, 16, [_]u8{
    ' ',
    '.',
    ',',
    ':',
    ';',
    '-',
    '~',
    '=',
    '+',
    '*',
    '#',
    '%',
    '&',
    '@',
    'B',
    'M',
});

pub const DisplayOptions = struct {
    size: v.Vec2(u16) = v.Vec2(u16).init(120, 30),
};

pub inline fn Display(comptime options: DisplayOptions) type {
    const CellBuffer: type = v.Matrix2(Cell, options.size.x, options.size.y);

    return struct {
        var original_buffer: CellBuffer = [_][120]Cell{[_]Cell{Cell{}} ** 120} ** 30;
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

                    var new_cell: Cell = _sprite.grid[dh][dw];

                    if (new_cell.value == light_levels.at(0)) continue;
                    if (light_levels.index(new_cell.value).? < light_levels.index(buf2[y][x].value).?) {
                        new_cell.foreground = new_cell.foreground.blend(buf2[y][x].foreground);
                    }

                    buf2[y][x] = new_cell;
                }
            }
        }

        fn applyPixel(at: v.Vec2(usize), cell_data: Cell) void {
            Cursor.move(@intCast(at.x), @intCast(at.y));
            print("\x1b[38;2;{d};{d};{d}m\x1b[48;2;{d};{d};{d}m{c}\x1b[0m", .{
                cell_data.foreground.red,
                cell_data.foreground.green,
                cell_data.foreground.blue,
                //
                cell_data.background.red,
                cell_data.background.green,
                cell_data.background.blue,
                //
                cell_data.value,
            });
        }

        pub fn apply() void {
            assert(buf1.len == buf2.len, "the buffers have mismatched sizes");

            for (0..buf1.len) |y| {
                for (0..buf1[0].len) |x| {
                    if (!buf1[y][x].eql(buf2[y][x])) {
                        buf1[y][x] = buf2[y][x];
                        applyPixel(.{ .x = x * 2, .y = y }, buf1[y][x]);
                        applyPixel(.{ .x = x * 2 + 1, .y = y }, buf1[y][x]);
                    }
                }
            }
        }
    };
}
