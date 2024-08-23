const std = @import("std");
const print = std.debug.print;

// const input = @import("./deps/zig-input.zig");
const String = @import("./deps/zig-string.zig").String;
const Vec2 = @import("./deps/vectors.zig").Vec2;

const events = @import("./sys/events.zig").events;

const screen = @import("./sys/screen.zig").screen;
const Cell = @import("./sys/screen.zig").Cell;
const Sprite = @import("./sys/screen.zig").Sprite;

const getInputter = @import("./sys/input.zig").getInputter;
const getKeyCodes = @import("./sys/input.zig").getKeyCodes;

var pos: Vec2(i32) = Vec2(i32).init(0, 5);
var rnd = std.Random.DefaultPrng.init(100);

pub fn testfn() void {
    const x: i32 = @intCast(rnd.random().int(u4));

    screen.blitString(Vec2(i32).init(pos.y + x, pos.x), "x");
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var allocator = gpa.allocator();

    const KeyCodes = getKeyCodes() catch {
        std.debug.print("The KeyCodes for this OS are not available, yet!", .{});
        return;
    };
    const Inputter = getInputter() catch {
        std.debug.print("The Inputter for this OS is not supported, yet!", .{});
        return;
    };
    Inputter.init(&allocator);
    defer Inputter.deinit();

    events.init(&allocator);
    defer events.deinit();


    screen.init(.{ .x = 120, .y = 30 });
    defer screen.deinit();
    screen.Cursor.hide();

    const sprite: *Sprite(5, 5) = @constCast(
        &Sprite(5, 5).init([_][5]Cell{
            [_]Cell{Cell{
                .value = '#',
                .foreground = .{ .red = 240, .green = 100, .blue = 73 },
            }} ** 5,
            [_]Cell{Cell{
                .value = '#',
                .foreground = .{ .red = 228, .green = 146, .blue = 115 },
            }} ** 5,
            [_]Cell{Cell{
                .value = '#',
                .foreground = .{ .red = 219, .green = 213, .blue = 110 },
            }} ** 5,
            [_]Cell{Cell{
                .value = '#',
                .foreground = .{ .red = 59, .green = 178, .blue = 115 },
            }} ** 5,
            [_]Cell{Cell{
                .value = '#',
                .foreground = .{ .red = 117, .green = 139, .blue = 253 },
            }} ** 5,
        }),
    );

    try events.on("update", testfn);

    while (true) {
        Inputter.update();
        screen.clearBuffer();

        if (Inputter.getKey(KeyCodes.A)) {
            pos.x -= 1;
        }
        if (Inputter.getKey(KeyCodes.D)) {
            pos.x += 1;
        }
        if (Inputter.getKey(KeyCodes.W)) {
            pos.y -= 1;
        }
        if (Inputter.getKey(KeyCodes.S)) {
            pos.y += 1;
        }

        if (Inputter.getKey(KeyCodes.ESCAPE)) {
            break;
        }
        

        sprite.render(pos);

        try events.call("update");
        screen.apply();
    }
}
