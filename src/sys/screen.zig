const std = @import("std");
const Vec2 = @import("../deps/vectors.zig").Vector2D;
const assert = @import("./assert.zig").assert;

const ScreenBuffer = [30][120]u8;

pub const screen = struct {
    var buf1: ScreenBuffer = [_][120]u8{[_]u8{' '} ** 120} ** 30;
    var buf2: ScreenBuffer = [_][120]u8{[_]u8{' '} ** 120} ** 30;

    const max_screen_size: Vec2 = .{ .x = 120, .y = 30 };

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

    pub fn render(at: Vec2, content: []const u8) void {
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
