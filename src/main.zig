const std = @import("std");
const print = std.debug.print;

const String = @import("../libs/zig-string.zig").String;

const e = @import("./engine/engine.zig").TAGe4;
const Vec2 = e.Vec2;

var pos = Vec2(f64).init(0, 5);
var rnd = std.Random.DefaultPrng.init(100);

// const assets = @import(".temp/assets.zig");

pub fn testfn() void {
    // const x: f64 = @floatFromInt(rnd.random().int(u4));

    // e.Screen.blitString(e.Point.init(pos.y + x, pos.x), "x");
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var allocator = gpa.allocator();

    try e.Assets.init();
    print("{s}", .{e.Assets.files});

    e.Time.start(60);

    const KeyCodes = e.Input.getKeyCodes(.{}) catch {
        std.debug.print("OS Not Supported", .{});
        return;
    };
    const Inputter = e.Input.getInputter(.{}) catch {
        std.debug.print("OS Not Supported", .{});
        return;
    };
    Inputter.init(&allocator);
    defer Inputter.deinit();

    const Events = e.EventHandler(.{});

    Events.init(&allocator);
    defer Events.deinit();

    const Screen = e.Display(.{});

    Screen.init();
    defer Screen.deinit();
    Screen.Cursor.hide();

    var sprite = e.Sprite.init(&allocator, 10, 5);
    defer sprite.deinit();
    sprite.populate(10, 5, [_][10]e.Cell{
        [_]e.Cell{.{ .value = '#' }} ** 10,
    } ** 5);

    try Events.on(.Update, testfn);

    while (true) {
        Inputter.update();
        Screen.clearBuffer();

        if (Inputter.getKey(KeyCodes.A)) {
            pos.x -= 100 * e.Time.delta;
        }
        if (Inputter.getKey(KeyCodes.D)) {
            pos.x += 100 * e.Time.delta;
        }
        if (Inputter.getKey(KeyCodes.W)) {
            pos.y -= 100 * e.Time.delta;
        }
        if (Inputter.getKey(KeyCodes.S)) {
            pos.y += 100 * e.Time.delta;
        }

        if (Inputter.getKey(KeyCodes.ESCAPE)) {
            break;
        }

        // assets.player_left_0.render(pos);
        // assets.player_left_0.render(pos.add(Vec2(f64).init(5, 5)));
        Screen.blit(pos, sprite);

        try Events.call(.Update);
        Screen.apply();
        e.Time.tick(60);
    }
}
