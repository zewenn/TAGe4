const std = @import("std");
const Vec2 = @import("../deps/vectors.zig").Vec2;
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

    pub fn moveCursor(x: u8, y: u8) void {
        var _x = x;
        var _y = y;

        if (_x >= max_screen_size.x) _x = @intCast(max_screen_size.x - 1);
        if (_y >= max_screen_size.y) _y = @intCast(max_screen_size.y - 1);

        print("\x1b[{d};{d}H", .{ _y + 1, _x + 1 });
    }

    pub fn clearBuffer() void {
        buf2 = [_][120]u8{[_]u8{' '} ** 120} ** 30;
    }

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
            // if (y == 5) {
            //     std.debug.print("buf1 {d} => {any}", .{y, buf1[y][0..10]});
            //     std.debug.print("buf2 {d} => {any}", .{y, buf2[y][0..10]});
            // }
            for (0..buf1[0].len) |x| {
                // std.debug.print("{d}:{d} => {d} / {d}\n", .{ y, x, buf1[y][x], buf2[y][x] });
                if (buf1[y][x] != buf2[y][x]) {
                    buf1[y][x] = buf2[y][x];
                    moveCursor(@intCast(x), @intCast(y));
                    print("{c}", .{buf1[y][x]});
                }
            }
        }
    }
};
