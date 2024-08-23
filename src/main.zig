const std = @import("std");
const print = std.debug.print;

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

const assets = @import(".temp/assets.zig");

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
        

        assets.player_left_0.render(pos);

        try events.call("update");
        screen.apply();
    }
}
