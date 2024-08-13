const std = @import("std");
const Vec2 = @import("../deps/vectors.zig").Vec2;
const assert = @import("./assert.zig").assert;

const ScreenBuffer = [30][120]u8;

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
    value: u8,
    foreground: Colour,
    background: Colour,

    pub fn eql(cell1: *Self, cell2: Self) bool {
        if (cell1.value != cell2.value) return false;
        if (!cell1.foreground.eql(cell2.foreground)) return false;
        if (!cell1.background.eql(cell2.background)) return false;

        return true;
    }
};

pub const screen = struct {
    var buf1: ScreenBuffer = [_][120]u8{[_]u8{' '} ** 120} ** 30;
    var buf2: ScreenBuffer = [_][120]u8{[_]u8{' '} ** 120} ** 30;

    const max_screen_size = Vec2(u8).init(120, 30);

    pub fn print(comptime bytes: []const u8, args: anytype) void {
        std.debug.print(bytes, args);
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
        buf2 = [_][120]u8{[_]u8{' '} ** 120} ** 30;
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

    pub fn render(at: Vec2(i32), content: []const u8) void {
        var _at: *Vec2(i32) = @constCast(&at);

        if (!_at.isInBounds(0, 119, 0, 29)) {
            return;
        }

        const start_x: usize = @intCast(at.x);
        const start_y: usize = @intCast(at.y);

        for (0..content.len) |x| {
            if (!isOnScreen(@intCast(start_x + x), @intCast(start_y))) continue;
            buf2[start_y][start_x + x] = content[x];
        }
    }

    pub fn apply() void {
        assert(buf1.len == buf2.len, "the buffers have mismatched sizes");

        for (0..buf1.len) |y| {
            for (0..buf1[0].len) |x| {
                if (buf1[y][x] != buf2[y][x]) {
                    buf1[y][x] = buf2[y][x];
                    Cursor.move(@intCast(x), @intCast(y));
                    print("{c}", .{buf1[y][x]});
                }
            }
        }
    }
};
