const std = @import("std");
const print = std.debug.print;

const input = @import("./deps/zig-input.zig");
const String = @import("./deps/zig-string.zig").String;
const Vec2 = @import("./deps/vectors.zig").Vec2;

const events = @import("./sys/events.zig").events;
const screen = @import("./sys/screen.zig").screen;
const Cell = @import("./sys/screen.zig").Cell;
const Sprite = @import("./sys/screen.zig").Sprite;

var pos: Vec2(i32) = Vec2(i32).init(30, 29);

pub fn testfn() void {
    screen.blitString(pos, "x");
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var allocator = gpa.allocator();

    events.init(&allocator);
    defer events.deinit();

    // try events.on("update", testfn);

    var last_char: u8 = 0;

    screen.init();
    screen.Cursor.hide();

    const sprite: *Sprite(5, 5) = @constCast(
        &Sprite(5, 5).init([_][5]Cell{[_]Cell{
            Cell{
                .value = 'H',
                .foreground = .{ .red = 240, .green = 100, .blue = 73 },
            },
            Cell{
                .value = 'H',
                .foreground = .{ .red = 228, .green = 146, .blue = 115 },
            },
            Cell{
                .value = 'H',
                .foreground = .{ .red = 219, .green = 213, .blue = 110 },
            },
            Cell{
                .value = 'H',
                .foreground = .{ .red = 59, .green = 178, .blue = 115 },
            },
            Cell{
                .value = 'H',
                .foreground = .{ .red = 117, .green = 139, .blue = 253 },
            },
        }} ** 5),
    );

    while (true) {
        screen.clearBuffer();

        // screen.blit(pos, @constCast(&sprite));
        sprite.render(pos);

        // screen.render(.{ .x = 5, .y = 5 }, test_print);
        // screen.blitString(pos, test_print);

        const input_char = input.getKeyDown();
        last_char = input_char;

        switch (input_char) {
            input.keys.ESCAPE => break,
            input.keys.a => pos.x -= 1,
            input.keys.d => pos.x += 1,
            input.keys.w => pos.y -= 1,
            input.keys.s => pos.y += 1,
            else => {},
        }
        try events.call("update");
        screen.apply();
    }
    screen.deinit();
}
