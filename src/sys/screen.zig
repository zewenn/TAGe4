const std = @import("std");
const Vec2 = @import("../deps/vectors.zig").Vec2;
const assert = @import("./z.zig").assert;

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

pub fn Sprite(comptime width: usize, comptime height: usize) type {
    return struct {
        const Self = @This();
        grid: [height][width]Cell,

        pub fn init(sprite: [height][width]Cell) Self {
            return .{ .grid = sprite };
        }

        pub fn render(self: *Self, at: Vec2(f32)) void {
            screen.blit(at, width, height, self);
        }

        pub fn isInBounds(_: *Self, at: Vec2(f32)) bool {
            var _at: *Vec2(f32) = @constCast(&at);
            var _at_end_x: Vec2(f32) = _at.add(.{
                .x = @floatFromInt(width),
                .y = 0,
            });
            var _at_end_y: Vec2(f32) = _at.add(.{
                .x = 0,
                .y = @floatFromInt(height),
            });
            var _at_end_xy: Vec2(f32) = _at.add(.{
                .x = @floatFromInt(width),
                .y = @floatFromInt(height),
            });

            const res = (_at.isInBounds(
                0,
                @floatFromInt(screen.max_screen_size.x - 1),
                0,
                @floatFromInt(screen.max_screen_size.y - 1),
            ) or
                _at_end_x.isInBounds(
                0,
                @floatFromInt(screen.max_screen_size.x - 1),
                0,
                @floatFromInt(screen.max_screen_size.y - 1),
            ) or
                _at_end_y.isInBounds(
                0,
                @floatFromInt(screen.max_screen_size.x - 1),
                0,
                @floatFromInt(screen.max_screen_size.y - 1),
            ) or
                _at_end_xy.isInBounds(
                0,
                @floatFromInt(screen.max_screen_size.x - 1),
                0,
                @floatFromInt(screen.max_screen_size.y - 1),
            ));

            // std.debug.print("{?} - {?} => {s}\n", .{ _at, _at_end_x, if (res) "true" else "false" });

            return res;
        }
    };
}

pub const ScreenBuffer: type = [30][120]Cell;
// pub const ScreenBuffer: type = [30][120]u8;

pub const screen = struct {
    var original_buffer: ScreenBuffer = [_][120]Cell{[_]Cell{Cell{}} ** 120} ** 30;
    // var buf1: ScreenBuffer = [_][120]u8{[_]u8{' '} ** 120} ** 30;
    var buf1: ScreenBuffer = undefined;
    var buf2: ScreenBuffer = undefined;

    var stdOut: std.fs.File = undefined;

    pub var max_screen_size = Vec2(u8).init(120, 30);

    pub fn print(comptime bytes: []const u8, args: anytype) void {
        stdOut.writer().print(bytes, args) catch return;
    }

    pub fn init(comptime screen_size: Vec2(u8)) void {
        clearScreen();

        max_screen_size = screen_size;

        Cursor.hide();
        stdOut = std.io.getStdOut();

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

    fn isOnScreen(x: i32, y: i32) bool {
        if ((x < 0 or y < 0) or (x >= max_screen_size.x or y >= max_screen_size.y)) {
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

            if (_x >= max_screen_size.x) _x = @intCast(max_screen_size.x - 1);
            if (_y >= max_screen_size.y) _y = @intCast(max_screen_size.y - 1);

            print("\x1b[{d};{d}H", .{ _y + 1, _x + 1 });
        }
    };

    pub fn blitString(at: Vec2(f32), content: []const u8) void {
        var _at: Vec2(i32) = Vec2(i32).init(
            @intFromFloat(at.x),
            @intFromFloat(at.y),
        );

        if (!_at.isInBounds(0, max_screen_size.x - 1, 0, max_screen_size.x - 1)) {
            return;
        }

        const start_x: usize = @intCast(_at.x);
        const start_y: usize = @intCast(_at.y);

        for (0..content.len) |x| {
            if (!isOnScreen(@intCast(start_x + x), @intCast(start_y))) continue;
            buf2[start_y][start_x + x].value = content[x];
        }
    }

    pub fn blit(at: Vec2(f32), comptime w: usize, comptime h: usize, sprite: *Sprite(w, h)) void {
        const _sprite = sprite.grid;

        const _at = Vec2(i32).init(@intFromFloat(at.x), @intFromFloat(at.y));

        if (!sprite.isInBounds(at)) {
            return;
        }

        const start_x = _at.x;
        const start_y = _at.y;

        for (0.._sprite.len) |dh| {
            for (0.._sprite[0].len) |dw| {
                const px: i32 = start_x + @as(i32, @intCast(dw));
                const py: i32 = start_y + @as(i32, @intCast(dh));

                if (!isOnScreen(px, py)) continue;

                const x: usize = @intCast(px);
                const y: usize = @intCast(py);

                buf2[y][x] = _sprite[dh][dw];
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
