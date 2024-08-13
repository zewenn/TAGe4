const std = @import("std");
const print = std.debug.print;

const input = @import("./deps/zig-input.zig");
const String = @import("./deps/zig-string.zig").String;
const Vec2 = @import("./deps/vectors.zig").Vec2;

const events = @import("./sys/events.zig").events;
const screen = @import("./sys/screen.zig").screen;

var pos: Vec2(i32) = Vec2(i32).init(30, 29);

pub fn testfn() void {
    screen.render(pos, "x");
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var allocator = gpa.allocator();

    events.init(&allocator);
    defer events.deinit();

    // try events.on("update", testfn);

    var last_char: u8 = 0;

    screen.clearScreen();
    screen.Cursor.hide();
    while (true) {
        screen.clearBuffer();

        const test_print = try std.fmt.allocPrint(
            allocator,
            "{d}:{d}",
            .{ pos.x, pos.y },
        );
        defer allocator.free(test_print);

        // screen.render(.{ .x = 5, .y = 5 }, test_print);
        screen.render(pos, test_print);

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
    screen.Cursor.show();
}
