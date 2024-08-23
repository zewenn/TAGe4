const std = @import("std");
const print = std.debug.print;

// const input = @import("./deps/zig-input.zig");
const String = @import("./deps/zig-string.zig").String;
const Vec2 = @import("./deps/vectors.zig").Vec2;

const events = @import("./sys/events.zig").events;
const screen = @import("./sys/screen.zig").screen;
const Cell = @import("./sys/screen.zig").Cell;
const Sprite = @import("./sys/screen.zig").Sprite;
// const input = @import("./sys/input.zig").input;
const osx_inpt = @import("./sys/input.zig").OsXInputter;
const osx_keys = @import("./sys/input.zig").OsXKeyCodes;

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

    // input.init(&allocator);
    // defer input.deinit();
    const Input = osx_inpt.get();
    Input.init(&allocator);
    defer Input.deinit();

    events.init(&allocator);
    defer events.deinit();

    // try events.on("update", testfn);
    // var last_char: u8 = 0;

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
    // _ = sprite;

    // var tempx: f32 = 0;

    try events.on("update", testfn);

    while (true) {
        Input.update();
        screen.clearBuffer();

        if (Input.getKey(osx_keys.A)) {
            pos.x -= 1;
        }
        if (Input.getKey(osx_keys.D)) {
            pos.x += 1;
        }
        if (Input.getKey(osx_keys.W)) {
            pos.y -= 1;
        }
        if (Input.getKey(osx_keys.S)) {
            pos.y += 1;
        }

        if (Input.getKey(osx_keys.ESCAPE)) {
            break;
        }
        

        // screen.clearScreen();
        // std.debug.print("{any}\n\n", .{sdl.getKeyboardState()});

        // // screen.blit(pos, @constCast(&sprite));

        // if (tempx < 119.0)
        // tempx += 0.001;
        // // print("{d}-{d}\n", .{tempx, )});

        // if (@rem(tempx, 10) > 8) {
        //     // print("{d}", .{tempx});
        //     tempx = 0;
        //     pos.x += 1;
        // }

        sprite.render(pos);

        try events.call("update");
        screen.apply();
    }
}
